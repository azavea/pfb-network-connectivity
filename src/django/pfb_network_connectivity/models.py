"""
Models related to analysis results.
"""

from __future__ import unicode_literals

from django.db import models

from base.models import PFBModel


class Area(models.Model):
    """Area used for analysis

    TODO: fully implement
    """

    def __repr__(self):
        return "<Area: {}>".format(self.name)

    name = models.TextField()
