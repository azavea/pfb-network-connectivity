from __future__ import unicode_literals

import os
import uuid

from django.db import models

from localflavor.us.models import USStateField
import us

from pfb_network_connectivity.models import PFBModel
from users.models import Organization


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

    status = models.CharField(choices=Status.CHOICES,
                              default=Status.CREATED,
                              max_length=12,
                              help_text='The current status of the AnalysisJob')

    neighborhood = models.ForeignKey(Neighborhood,
                                     related_name='analysis_jobs',
                                     on_delete=models.CASCADE)

    def run(self):
        """ Run the analysis job

        TODO: Implement

        """
        pass
