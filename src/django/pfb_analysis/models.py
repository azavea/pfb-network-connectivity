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
from django.contrib.gis.db.models import MultiPolygonField, PointField
from django.contrib.gis.geos import GEOSGeometry, MultiPolygon
from django.contrib.postgres.fields import JSONField
from django.core.files import File
from django.db import models
from django.utils.text import slugify

import botocore
import boto3
import fiona
from fiona.crs import from_epsg
from localflavor.us.models import USStateField
import us

from pfb_network_connectivity.models import PFBModel
from users.models import Organization
from .functions import ObjectAtPath


logger = logging.getLogger(__name__)

# degree to which to simplify boundaries
# https://docs.djangoproject.com/en/1.11/ref/contrib/gis/geos/#django.contrib.gis.geos.GEOSGeometry.simplify
SIMPLIFICATION_TOLERANCE_MORE = 0.001
SIMPLIFICATION_TOLERANCE_LESS = 0.0001


def get_neighborhood_file_upload_path(instance, filename):
    """ Upload each boundary file to its own directory """
    return 'neighborhood_boundaries/{0}/{1}'.format(instance.name, os.path.basename(filename))


def simplify_geom(geom):
    """Attempt to simplify a multipolygon, will fallback options

    Fall back to simplify less, or none at all.
    """
    try:
        simple = MultiPolygon([geom.simplify(SIMPLIFICATION_TOLERANCE_MORE)])
    except:
        simple = None
    try:
        # sometimes an empty geometry may result, likely due to
        # https://trac.osgeo.org/geos/ticket/741
        if not simple or simple.empty or not simple.valid:
            simple = MultiPolygon([geom.simplify(SIMPLIFICATION_TOLERANCE_LESS)])
        if simple.empty or not simple.valid:
            simple = geom
    except:
        simple = geom
    return simple


def create_environment(**kwargs):
    """ Format args for AWS environment

    Writes argument pairs to an array {name, value} objects, which is what AWS wants for
    environment overrides.
    """
    return [{'name': k, 'value': v} for k, v in kwargs.iteritems()]


class Neighborhood(PFBModel):
    """Neighborhood boundary used for an AnalysisJob """

    def __str__(self):
        return "<Neighborhood: {} ({})>".format(self.name, self.organization.name)

    uuid = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.SlugField(max_length=256, help_text='Unique slug for neighborhood')
    label = models.CharField(max_length=256, help_text='Human-readable label for neighborhood')
    geom = MultiPolygonField(srid=4326, blank=True, null=True)
    geom_simple = MultiPolygonField(srid=4326, blank=True, null=True)
    geom_pt = PointField(srid=4326, blank=True, null=True)
    organization = models.ForeignKey(Organization,
                                     related_name='neighborhoods',
                                     on_delete=models.CASCADE)
    state_abbrev = USStateField(help_text='The US state of the uploaded neighborhood')
    boundary_file = models.FileField(max_length=1024,
                                     upload_to=get_neighborhood_file_upload_path,
                                     help_text='A zipped shapefile boundary to run the ' +
                                               'bike network analysis on')

    def save(self, *args, **kwargs):
        """ Override to do validation checks before saving, which disallows blank state_abbrev """
        if not self.name:
            self.name = self.name_for_label(self.label)
        self.full_clean()
        self._set_geom_from_boundary_file()
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
            self.geom = geom
            self.geom_simple = simplify_geom(geom)
            self.geom_pt = geom.centroid
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

    def _set_geom_from_boundary_file(self, overwrite=False):
        """ Opens a local copy of the boundary file and sets geom field

        Does not save model
        Copies the geom of the first feature found in the shapefile into geom, to be consistent
        with the rest of the app
        No explicit error handling/logging, will raise original exception if failure

        """
        if overwrite or (self.boundary_file and not self.geom):
            try:
                tmpdir = tempfile.mkdtemp()
                local_zipfile = os.path.join(tmpdir, '{}.zip'.format(self.name))
                with open(local_zipfile, 'wb') as zip_handle:
                    zip_handle.write(self.boundary_file.read())
                with zipfile.ZipFile(local_zipfile, 'r') as zip_handle:
                    zip_handle.extractall(tmpdir)
                shpfiles = [filename for filename in os.listdir(tmpdir) if filename.endswith('shp')]
                shp_filename = os.path.join(tmpdir, shpfiles[0])
                with fiona.open(shp_filename, 'r') as shp_handle:
                    feature = next(shp_handle)
                    geom = GEOSGeometry(json.dumps(feature['geometry']))
                    if geom.geom_type == 'Polygon':
                        geom = MultiPolygon([geom])
                    self.geom = geom
                    self.geom_simple = simplify_geom(geom)
                    self.geom_pt = geom.centroid
            finally:
                shutil.rmtree(tmpdir, ignore_errors=True)

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
            try:
                job.cancel(reason=reason)
            except Exception as e:
                if job.batch_job_id:
                    logger.warning('Cancelling {} failed'.format(job.batch_job_id))
                logger.exception('Cancelling job {} failed: {}'.format(job, e))


class AnalysisJobManager(models.Manager):
    def get_queryset(self):
        qs = super(AnalysisJobManager, self).get_queryset()
        return qs.annotate(overall_score=ObjectAtPath('overall_scores',
                                                      ('overall_score', 'score_normalized')))


def generate_analysis_job_def():
    return settings.PFB_AWS_BATCH_ANALYSIS_JOB_DEFINITION_NAME_REVISION


def generate_tilemaker_job_def():
    return settings.PFB_AWS_BATCH_TILEMAKER_JOB_DEFINITION_NAME_REVISION


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
        EXPORTED = 'EXPORTED'
        TILING = 'TILING'
        COMPLETE = 'COMPLETE'
        CANCELLED = 'CANCELLED'
        ERROR = 'ERROR'

        ACTIVE_STATUSES = (CREATED, QUEUED, IMPORTING, BUILDING, CONNECTIVITY,
                           METRICS, EXPORTING, EXPORTED, TILING,)
        SUCCESS_STATUS = COMPLETE
        DONE_STATUSES = (SUCCESS_STATUS, CANCELLED, ERROR,)

        CHOICES = (
            (CREATED, 'Created',),
            (QUEUED, 'Queued',),
            (IMPORTING, 'Importing Data',),
            (BUILDING, 'Building Network Graph',),
            (CONNECTIVITY, 'Calculating Connectivity',),
            (METRICS, 'Calculating Graph Metrics',),
            (EXPORTING, 'Exporting Results',),
            (EXPORTED, 'Analysis Finished',),
            (TILING, 'Generating Map Tiles',),
            (COMPLETE, 'Complete',),
            (CANCELLED, 'Cancelled',),
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
    overall_scores = JSONField(db_index=True, default=dict)
    census_block_count = models.PositiveIntegerField(blank=True, null=True)

    analysis_job_definition = models.CharField(max_length=50, default=generate_analysis_job_def)
    _analysis_job_name = models.CharField(max_length=50, default='')
    tilemaker_job_definition = models.CharField(max_length=50, default=generate_tilemaker_job_def)
    _tilemaker_job_name = models.CharField(max_length=50, default='')

    objects = AnalysisJobManager()

    @property
    def status(self):
        """ Return current status for this job """
        latest_update = self.status_updates.last()
        return latest_update.status if latest_update else self.Status.CREATED

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
    def analysis_job_name(self):
        if not self._analysis_job_name:
            job_definition = self.analysis_job_definition
            # Due to CloudWatch logs limits, job name must be no more than 50 chars
            # so force truncate to that to keep jobs from failing
            definition_name, revision = job_definition.split(':')
            job_name = '{}--{}--{}'.format(definition_name[:30], revision, str(self.uuid)[:8])
            self._analysis_job_name = job_name
            self.save()
        return self._analysis_job_name

    @property
    def tilemaker_job_name(self):
        if not self._tilemaker_job_name:
            job_definition = self.tilemaker_job_definition
            # Due to CloudWatch logs limits, job name must be no more than 50 chars
            # so force truncate to that to keep jobs from failing
            definition_name, revision = job_definition.split(':')
            job_name = '{}--{}--{}'.format(definition_name[:30], revision, str(self.uuid)[:8])
            self._tilemaker_job_name = job_name
            self.save()
        return self._tilemaker_job_name

    @property
    def census_blocks_url(self):
        return self._s3_url_for_result_resource('neighborhood_census_blocks.zip')

    @property
    def connected_census_blocks_url(self):
        return self._s3_url_for_result_resource('neighborhood_connected_census_blocks.csv.zip')

    @property
    def destinations_urls(self):
        """ Return a dict of the available destinations files for this job """
        return {
            destination: self._s3_url_for_result_resource('neighborhood_{}.geojson'
                                                          .format(destination))
            for destination in settings.PFB_ANALYSIS_DESTINATIONS
        }

    @property
    def overall_scores_url(self):
        return self._s3_url_for_result_resource('neighborhood_overall_scores.csv')

    @property
    def score_inputs_url(self):
        return self._s3_url_for_result_resource('neighborhood_score_inputs.csv')

    @property
    def logs_url(self):
        url = ('https://console.aws.amazon.com/cloudwatch/home?region={aws_region}' +
               '#logStream:group=/aws/batch/job;prefix={batch_job_name}/{batch_job_id}' +
               ';streamFilter=typeLogStreamPrefix')
        return url.format(aws_region=settings.AWS_REGION,
                          batch_job_name=self.analysis_job_name,
                          batch_job_id=self.batch_job_id)

    @property
    def running_time(self):
        """ Return the running time of the job in seconds """
        first_update = self.status_updates.filter(status=self.Status.IMPORTING).first()
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

    @property
    def ways_url(self):
        return self._s3_url_for_result_resource('neighborhood_ways.zip')

    def cancel(self, reason=None):
        """ Cancel the analysis job, if its running """
        if not reason:
            reason = 'AnalysisJob terminated by user at {}'.format(datetime.utcnow())

        if self.status in self.Status.ACTIVE_STATUSES:
            logger.info('Cancelling job: {}'.format(self))
            old_status = self.status
            self.update_status(self.Status.CANCELLED)
            if self.batch_job_id is not None:
                try:
                    client = boto3.client('batch')
                    client.terminate_job(jobId=self.batch_job_id, reason=reason)
                except:
                    self.update_status(old_status,
                                       'REVERTED',
                                       'Reverted due to failure cancelling job in AWS Batch')
                    raise

    def base_environment(self):
        """ Convenience method for copying the environment to hand to batch jobs """

        # Since we run django manage commands in the analysis container, it needs a copy of
        # all the environment variables that this app needs, most of which are conveniently
        # prefixed with 'PFB_'
        # Set these first so they can be overridden by job specific settings below
        environment = {key: val for (key, val) in os.environ.items()
                       if key.startswith('PFB_') and val is not None}
        # For the ones without the 'PFB_' prefix, send the settings rather than the original
        # environment variables because the environment variables might be None, which is not
        # acceptable as a container override environment value, but the settings values will be set
        # to whatever they default to in settings.
        environment.update({
            'DJANGO_ENV': settings.DJANGO_ENV,
            'DJANGO_LOG_LEVEL': settings.DJANGO_LOG_LEVEL,
            'AWS_DEFAULT_REGION': settings.AWS_REGION,
        })
        return environment

    def run(self):
        """ Run the analysis job, configuring ENV appropriately """
        if self.status != self.Status.CREATED:
            logger.warn('Attempt to re-run job: {}. Skipping.'.format(self.uuid))
            return

        # Provide the base environment to enable runnin Django commands in the container
        environment = self.base_environment()
        # Job-specific settings
        environment.update({
            'NB_TEMPDIR': os.path.join('/tmp', str(self.uuid)),
            'PGDATA': os.path.join('/pgdata', str(self.uuid)),
            'PFB_SHPFILE_URL': self.neighborhood.boundary_file.url,
            'PFB_STATE': self.neighborhood.state_abbrev,
            'PFB_STATE_FIPS': self.neighborhood.state.fips,
            'PFB_JOB_ID': str(self.uuid),
            'AWS_STORAGE_BUCKET_NAME': settings.AWS_STORAGE_BUCKET_NAME,
            'PFB_S3_RESULTS_PATH': self.s3_results_path
        })
        if self.osm_extract_url:
            environment['PFB_OSM_FILE_URL'] = self.osm_extract_url

        # Workaround for not being able to run development jobs on the actual batch cluster:
        # bail out with a helpful message
        if settings.DJANGO_ENV == 'development':
            logger.warn("Can't actually run development analysis jobs on AWS. Try this:"
                        "\nPFB_JOB_ID='{PFB_JOB_ID}' PFB_S3_RESULTS_PATH='{PFB_S3_RESULTS_PATH}' "
                        "./scripts/run-local-analysis "
                        "'{PFB_SHPFILE_URL}' {PFB_STATE} {PFB_STATE_FIPS}".format(**environment))
            self.generate_tiles()
            return

        client = boto3.client('batch')
        container_overrides = {
            'environment': create_environment(**environment),
        }
        try:
            response = client.submit_job(
                jobName=self.analysis_job_name,
                jobDefinition=self.analysis_job_definition,
                jobQueue=settings.PFB_AWS_BATCH_ANALYSIS_JOB_QUEUE_NAME,
                containerOverrides=container_overrides)
            self.batch_job_id = response['jobId']
            self.save()
            self.update_status(self.Status.QUEUED)
        except (botocore.exceptions.BotoCoreError, KeyError):
            logger.exception('Error starting AnalysisJob {}'.format(self.uuid))
        else:
            self.generate_tiles()

    def generate_tiles(self):
        environment = self.base_environment()
        environment.update({
            'PFB_JOB_ID': str(self.uuid),
            'AWS_STORAGE_BUCKET_NAME': settings.AWS_STORAGE_BUCKET_NAME,
            'PFB_S3_RESULTS_PATH': self.s3_results_path,
            'PFB_S3_TILES_PATH': self.s3_tiles_path
        })

        # Workaround for not being able to run development jobs on the actual batch cluster:
        # bail out with a helpful message
        if settings.DJANGO_ENV == 'development':
            logger.warn("Can't actually run development tiling jobs on AWS. Try this:"
                        "\nAWS_STORAGE_BUCKET_NAME='{AWS_STORAGE_BUCKET_NAME}' "
                        "PFB_JOB_ID='{PFB_JOB_ID}' "
                        "PFB_S3_RESULTS_PATH='{PFB_S3_RESULTS_PATH}' "
                        "PFB_S3_TILES_PATH='{PFB_S3_TILES_PATH}' "
                        "docker-compose run tilemaker".format(**environment))
            return

        job_params = {
            'jobName': self.tilemaker_job_name,
            'jobDefinition': self.tilemaker_job_definition,
            'jobQueue': settings.PFB_AWS_BATCH_TILEMAKER_JOB_QUEUE_NAME,
            'dependsOn': [{'jobId': self.batch_job_id}],
            'containerOverrides': {
                'environment': create_environment(**environment),
            }
        }
        client = boto3.client('batch')
        try:
            response = client.submit_job(**job_params)
            logger.info('Exporting tiles for AnalysisJob {}, job {}'.format(self.uuid,
                                                                            response['jobId']))
        except Exception:
            logger.exception('Error starting tile export for AnalysisJob {}'.format(self.uuid))
            raise

    def update_status(self, status, step='', message=''):
        if self.status != self.Status.CANCELLED:
            self.status_updates.create(job=self, status=status, step=step, message=message)

    @property
    def s3_results_path(self):
        return 'results/{jobId}'.format(jobId=str(self.uuid))

    @property
    def s3_tiles_path(self):
        return '{}/tiles'.format(self.s3_results_path)

    def _s3_url_for_result_resource(self, filename):
        key = '/'.join((self.s3_results_path, filename))
        s3 = boto3.client('s3')
        return s3.generate_presigned_url(
            ClientMethod='get_object',
            ExpiresIn=settings.PFB_ANALYSIS_PRESIGNED_URL_EXPIRES,
            Params={
                'Bucket': settings.AWS_STORAGE_BUCKET_NAME,
                'Key': key
            }
        )


class AnalysisJobStatusUpdate(models.Model):
    """ Related model for AnalysisJob, to provide record of status updates as job progresses

    Rather than creating these objects directly, they should be created using:
        AnalysisJob.update_status()

    """
    job = models.ForeignKey(AnalysisJob, related_name='status_updates', on_delete=models.CASCADE)
    status = models.CharField(choices=AnalysisJob.Status.CHOICES, max_length=12)
    step = models.CharField(max_length=50)
    message = models.CharField(max_length=256, null=True, blank=True)
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        # NOTE: Changing ordering=timestamp would invalidate assumptions about the ordering of
        #       these objects elsewhere in the model. Proceed with caution.
        ordering = ('timestamp',)

    def save(self, *args, **kwargs):
        """ Override to update `modified_at` on the related AnalysisJob """
        super(AnalysisJobStatusUpdate, self).save(*args, **kwargs)
        # The modified_at field is auto_now=True, so just saving updates it
        self.job.save()


class AnalysisScoreMetadata(models.Model):
    """ Used to hold metadata for each of the scores saved in AnalysisJob.overall_scores

    The unique name field here is matched against the top-level keys in the
    AnalysisJob.overall_scores field so that we only have to store score metadata in one place

    """
    name = models.CharField(max_length=128, primary_key=True)
    label = models.CharField(max_length=256, blank=True, null=True,
                             help_text='Short descriptive name')
    category = models.CharField(max_length=128, blank=True, null=True,
                                help_text='Used to group scores with the same category together')
    description = models.CharField(max_length=1024, blank=True, null=True,
                                   help_text='Long description of the metric')

    class Meta:
        ordering = ('name',)
