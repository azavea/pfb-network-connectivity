from __future__ import unicode_literals

import os
import logging
import uuid

from django.conf import settings
from django.db import models

import botocore
import boto3
from localflavor.us.models import USStateField
import us

from pfb_network_connectivity.models import PFBModel
from users.models import Organization


logger = logging.getLogger(__name__)


def get_neighborhood_file_upload_path(instance, filename):
    """ Upload each boundary file to its own directory """
    return 'neighborhood_boundaries/{0}/{1}'.format(instance.name, os.path.basename(filename))


class Neighborhood(models.Model):
    """Neighborhood boundary used for an AnalysisJob """

    def __repr__(self):
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
        self.full_clean()
        super(Neighborhood, self).save(*args, **kwargs)

    @property
    def state(self):
        """ Return the us.states.State object associated with this boundary

        https://github.com/unitedstates/python-us

        """
        return us.states.lookup(self.state_abbrev)

    class Meta:
        unique_together = ('name', 'organization',)


class AnalysisJob(PFBModel):

    class Status(object):
        CREATED = 'CREATED'
        IMPORTING = 'IMPORTING'
        BUILDING = 'BUILDING'
        CONNECTIVITY = 'CONNECTIVITY'
        METRICS = 'METRICS'
        EXPORTING = 'EXPORTING'
        COMPLETE = 'COMPLETE'
        ERROR = 'ERROR'

        CHOICES = (
            (CREATED, 'Created',),
            (IMPORTING, 'Importing Data',),
            (BUILDING, 'Building Network Graph',),
            (CONNECTIVITY, 'Calculating Connectivity',),
            (METRICS, 'Calculating Graph Metrics',),
            (EXPORTING, 'Exporting Results',),
            (COMPLETE, 'Complete',),
            (ERROR, 'Error',),
        )

    batch_job_id = models.CharField(max_length=256, blank=True, null=True)
    neighborhood = models.ForeignKey(Neighborhood,
                                     related_name='analysis_jobs',
                                     on_delete=models.CASCADE)
    status = models.CharField(choices=Status.CHOICES,
                              default=Status.CREATED,
                              max_length=12,
                              help_text='The current status of the AnalysisJob')

    def run(self):
        """ Run the analysis job, configuring ENV appropriately """
        def create_environment(**kwargs):
            return [{'name': k, 'value': v} for k, v in kwargs.iteritems()]

        if self.batch_job_id is not None:
            logger.warn('Attempt to re-run job: {}. Skipping.'.format(self.uuid))
            return

        client = boto3.client('batch')
        job_definition = settings.PFB_AWS_BATCH_JOB_DEFINITION_NAME_REVISION
        # Due to CloudWatch logs limits, job name must be no more than 50 chars
        # so force truncate to that to keep jobs from failing
        definition_name, revision = job_definition.split(':')
        job_name = '{}--{}--{}'.format(definition_name[:30], revision, str(self.uuid)[:8])
        environment = create_environment(PFB_SHPFILE=self.neighborhood.boundary_file.url,
                                         PFB_STATE=self.neighborhood.state_abbrev,
                                         PFB_STATE_FIPS=self.neighborhood.state.fips)
        container_overrides = {
            'environment': environment,
        }
        response = client.submit_job(jobName=job_name,
                                     jobDefinition=job_definition,
                                     jobQueue=settings.PFB_AWS_BATCH_JOB_QUEUE_NAME,
                                     containerOverrides=container_overrides)
        try:
            self.batch_job_id = response['jobId']
            # TODO: Possibly refactor status to use the AWS Batch status rather than some
            #       custom status we may not have the ability to easily update
            self.status = self.Status.IMPORTING
            self.save()
        except (botocore.exceptions.BotoCoreError, KeyError):
            logger.exception('Error starting AnalysisJob {}'.format(self.uuid))

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
        except KeyError:
            logger.exception('Error retrieving AWS Batch job status for job'.format(self.uuid))
            return None
