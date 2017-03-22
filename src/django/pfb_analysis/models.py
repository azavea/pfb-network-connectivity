from __future__ import unicode_literals

from datetime import datetime
import logging
import json
import os
import shutil
import tempfile
import uuid
import zipfile

from django.conf import settings
from django.contrib.gis.geos import MultiPolygon
from django.core.files import File
from django.db import models
from django.utils.text import slugify

import botocore
import boto3
import fiona
from fiona.crs import from_epsg
from localflavor.us.models import USStateField
import us

from pfb_analysis.aws_batch import JobState
from pfb_network_connectivity.models import PFBModel
from users.models import Organization


logger = logging.getLogger(__name__)


def get_neighborhood_file_upload_path(instance, filename):
    """ Upload each boundary file to its own directory """
    return 'neighborhood_boundaries/{0}/{1}'.format(instance.name, os.path.basename(filename))


class Neighborhood(PFBModel):
    """Neighborhood boundary used for an AnalysisJob """

    def __str__(self):
        return "<Neighborhood: {} ({})>".format(self.name, self.organization.name)

    uuid = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.SlugField(max_length=256, help_text='Unique slug for neighborhood')
    label = models.CharField(max_length=256, help_text='Human-readable label for neighborhood')
    organization = models.ForeignKey(Organization,
                                     related_name='neighborhoods',
                                     on_delete=models.CASCADE)
    state_abbrev = USStateField(help_text='The US state of the uploaded neighborhood')
    boundary_file = models.FileField(upload_to=get_neighborhood_file_upload_path,
                                     help_text='A zipped shapefile boundary to run the ' +
                                               'bike network analysis on')

    def save(self, *args, **kwargs):
        """ Override to do validation checks before saving, which disallows blank state_abbrev """
        if not self.name:
            self.name = self.name_for_label(self.label)
        self.full_clean()
        super(Neighborhood, self).save(*args, **kwargs)

    def set_boundary_file(self, geom):
        """ Create a new boundary shapefile that mirrors geom, upload and save

        geom must be either a Polygon or MultiPolygon

        """
        boundary_file = None
        try:
            tmpdir = tempfile.mkdtemp()
            file_name = self.name
            local_shpfile = os.path.join(tmpdir, '{}.shp'.format(file_name))
            schema = {'geometry': 'MultiPolygon', 'properties': {}}
            with fiona.open(local_shpfile, 'w',
                            driver='ESRI Shapefile',
                            crs=from_epsg(4326),
                            schema=schema) as source:
                if geom.geom_type == 'Polygon':
                    geom = MultiPolygon([geom])
                feature = {
                    'geometry': json.loads(geom.json),
                    'properties': {}
                }
                source.write(feature)

            zip_filename = os.path.join(tmpdir, '{}.zip'.format(file_name))
            shpfiles = os.listdir(tmpdir)
            with zipfile.ZipFile(zip_filename, 'w') as zip_handle:
                for shpfile in shpfiles:
                    if shpfile.startswith(file_name):
                        zip_handle.write(os.path.join(tmpdir, shpfile), shpfile)
            boundary_file = File(open(zip_filename))
            self.boundary_file = boundary_file
            self.save()
        except:
            raise
        finally:
            if boundary_file:
                boundary_file.close()
            shutil.rmtree(tmpdir, ignore_errors=True)

    @property
    def state(self):
        """ Return the us.states.State object associated with this boundary

        https://github.com/unitedstates/python-us

        """
        return us.states.lookup(self.state_abbrev)

    @classmethod
    def name_for_label(cls, label):
        return slugify(label)

    class Meta:
        unique_together = ('name', 'organization',)


class AnalysisBatch(PFBModel):
    """ Container for a grouping of AnalysisJobs that are run together

    Allows us to track whether each job in a batch succeeded

    An AnalysisJob does not need to belong to an AnalysisBatch

    """
    def __str__(self):
        return '<AnalysisBatch: {} -- {}>'.format(str(self.uuid), self.created_at)

    def submit(self):
        """ Start all jobs in the batch """
        for job in self.jobs.all():
            job.run()

    def cancel(self, reason=None):
        """ Cancel all still-running jobs in the batch """
        def chunks(l, n):
            for i in range(0, len(l), n):
                yield l[i:i + n]

        if not reason:
            reason = 'AnalysisBatch terminated by user at {}'.format(datetime.utcnow())
        for job in self.jobs.all():
            job.cancel(reason=reason)


class AnalysisJob(PFBModel):

    def __str__(self):
        return "<AnalysisJob: {status} {neighborhood}>".format(status=self.status,
                                                               neighborhood=self.neighborhood.label)

    class Status(object):
        CREATED = 'CREATED'
        QUEUED = 'QUEUED'
        IMPORTING = 'IMPORTING'
        BUILDING = 'BUILDING'
        CONNECTIVITY = 'CONNECTIVITY'
        METRICS = 'METRICS'
        EXPORTING = 'EXPORTING'
        CANCELLED = 'CANCELLED'
        COMPLETE = 'COMPLETE'
        ERROR = 'ERROR'

        ACTIVE_STATUSES = (CREATED, QUEUED, IMPORTING, BUILDING, CONNECTIVITY,
                           METRICS, EXPORTING,)

        CHOICES = (
            (CREATED, 'Created',),
            (QUEUED, 'Queued',),
            (IMPORTING, 'Importing Data',),
            (BUILDING, 'Building Network Graph',),
            (CONNECTIVITY, 'Calculating Connectivity',),
            (METRICS, 'Calculating Graph Metrics',),
            (EXPORTING, 'Exporting Results',),
            (CANCELLED, 'Cancelled',),
            (COMPLETE, 'Complete',),
            (ERROR, 'Error',),
        )

    batch_job_id = models.CharField(max_length=256, blank=True, null=True)
    neighborhood = models.ForeignKey(Neighborhood,
                                     related_name='analysis_jobs',
                                     on_delete=models.CASCADE)
    osm_extract_url = models.URLField(max_length=2048, null=True, blank=True,
                                      help_text='Load OSM data for this neighborhood from ' +
                                                'a URL rather than pulling from Overpass API. ' +
                                                'The url must have a .osm file extension and ' +
                                                'may optionally be compressed via zip/bzip/gz, ' +
                                                'e.g. http://a.com/foo.osm or ' +
                                                'http://a.com/foo.osm.bz2')

    @property
    def status(self):
        """ Return current status for this job

        Uses AnalysisJobStatusUpdate but checks the batch job for situations that status
        updates don't cover.
        """
        # If there's no job ID that means it's brand new
        if self.batch_job_id is None:
            return self.Status.CREATED

        if self.batch_job_status == JobState.FAILED:
            return self.Status.ERROR
        try:
            # If the job hasn't failed and has sent any status updates, use the latest
            return self.status_updates.last().status
        except AttributeError:
            # Not failed but no status updates means it must be in the queue
            return self.Status.QUEUED

    @property
    def batch_job_status(self):
        """ Return current AWS Batch job status for this job

        List of available statuses: http://docs.aws.amazon.com/batch/latest/userguide/jobs.html
        TODO: Refactor to cache in db?
        """
        if not self.batch_job_id:
            return None
        client = boto3.client('batch')
        try:
            jobs = client.describe_jobs(jobs=[self.batch_job_id])['jobs']
            return jobs[0]['status']
        except (KeyError, IndexError):
            logger.exception('Error retrieving AWS Batch job status for job'.format(self.uuid))
            return None

    batch = models.ForeignKey(AnalysisBatch,
                              related_name='jobs',
                              on_delete=models.CASCADE,
                              null=True, blank=True)

    @property
    def batch_job_name(self):
        job_definition = settings.PFB_AWS_BATCH_JOB_DEFINITION_NAME_REVISION
        # Due to CloudWatch logs limits, job name must be no more than 50 chars
        # so force truncate to that to keep jobs from failing
        definition_name, revision = job_definition.split(':')
        return '{}--{}--{}'.format(definition_name[:30], revision, str(self.uuid)[:8])

    @property
    def logs_url(self):
        url = ('https://console.aws.amazon.com/cloudwatch/home?region={aws_region}' +
               '#logStream:group=/aws/batch/job;prefix={batch_job_name}/{batch_job_id}' +
               ';streamFilter=typeLogStreamPrefix')
        return url.format(aws_region=settings.AWS_REGION,
                          batch_job_name=self.batch_job_name,
                          batch_job_id=self.batch_job_id)

    @property
    def running_time(self):
        """ Return the running time of the job in seconds """
        first_update = self.status_updates.first()
        last_update = self.status_updates.last()
        if first_update is None or last_update is None:
            return 0
        start = first_update.timestamp
        end = last_update.timestamp
        diff = end - start
        return int(diff.total_seconds())

    @property
    def start_time(self):
        """ Return start time of the job as a datetime object """
        first_update = self.status_updates.first()
        return first_update.timestamp if first_update else None

    def cancel(self, reason=None):
        """ Cancel the analysis job, if its running """
        if not reason:
            reason = 'AnalysisJob terminated by user at {}'.format(datetime.utcnow())

        if self.status in self.Status.ACTIVE_STATUSES:
            client = boto3.client('batch')
            client.terminate_job(jobId=self.batch_job_id, reason=reason)
            AnalysisJobStatusUpdate.objects.create(job=self, status=self.Status.CANCELLED, step='')

    def run(self):
        """ Run the analysis job, configuring ENV appropriately """
        def create_environment(**kwargs):
            return [{'name': k, 'value': v} for k, v in kwargs.iteritems()]

        if self.batch_job_id is not None:
            logger.warn('Attempt to re-run job: {}. Skipping.'.format(self.uuid))
            return

        client = boto3.client('batch')

        # Since we run django manage commands in the analysis container, it needs a copy of
        # all the environment variables that this app needs, most of which are conveniently
        # prefixed with 'PFB_'
        # Set these first so they can be overridden by job specific settings below
        environment = {key: val for (key, val) in os.environ.items()
                       if key.startswith('PFB_') and val is not None}
        environment.update({
            'PGDATA': os.path.join('/pgdata', str(self.uuid)),
            'PFB_SHPFILE_URL': self.neighborhood.boundary_file.url,
            'PFB_STATE': self.neighborhood.state_abbrev,
            'PFB_STATE_FIPS': self.neighborhood.state.fips,
            'PFB_JOB_ID': str(self.uuid),
            'AWS_STORAGE_BUCKET_NAME': settings.AWS_STORAGE_BUCKET_NAME,

            # For ENV variables that aren't prefixed with 'PFB_', send the settings rather
            # than the original environment variables because the environment variables
            # might be None, which is not acceptable as a container override environment
            # value, but the settings values will be set to whatever they default to in settings.
            'DJANGO_ENV': settings.DJANGO_ENV,
            'DJANGO_LOG_LEVEL': settings.DJANGO_LOG_LEVEL,
            'AWS_DEFAULT_REGION': settings.AWS_REGION,
        })
        if self.osm_extract_url:
            environment['PFB_OSM_FILE_URL'] = self.osm_extract_url

        container_overrides = {
            'environment': create_environment(**environment),
        }
        response = client.submit_job(jobName=self.batch_job_name,
                                     jobDefinition=settings.PFB_AWS_BATCH_JOB_DEFINITION_NAME_REVISION, # NOQA
                                     jobQueue=settings.PFB_AWS_BATCH_JOB_QUEUE_NAME,
                                     containerOverrides=container_overrides)
        try:
            self.batch_job_id = response['jobId']
            self.save()
            AnalysisJobStatusUpdate.objects.create(job=self,
                                                   status=self.Status.CREATED,
                                                   step='CREATED')
        except (botocore.exceptions.BotoCoreError, KeyError):
            logger.exception('Error starting AnalysisJob {}'.format(self.uuid))


class AnalysisJobStatusUpdate(models.Model):
    job = models.ForeignKey(AnalysisJob, related_name='status_updates', on_delete=models.CASCADE)
    status = models.CharField(choices=AnalysisJob.Status.CHOICES, max_length=12)
    step = models.CharField(max_length=50)
    message = models.CharField(max_length=256, null=True, blank=True)
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        # NOTE: Changing ordering=timestamp would invalidate assumptions about the ordering of
        #       these objects elsewhere in the model. Proceed with caution.
        ordering = ('timestamp',)
