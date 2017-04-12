"""
Models related to analysis results.
"""

from __future__ import unicode_literals
import uuid

from django.contrib.gis.db import models


class PFBModel(models.Model):
    """Base class for most database models
    This base class includes attributes that will be common
    across multiple apps for this project.
    Attributes:
        uuid (str): unique identifier for object
        created_at (datetime.datetime): timestamp for object creation
        modified_at (datetime.datetime): timestamp for object edits
        created_by (users.PFBUser): user that created object
        modified_by (users.PFBUser): last user that modified object
    """

    uuid = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    created_at = models.DateTimeField(auto_now_add=True)
    modified_at = models.DateTimeField(auto_now=True)

    created_by = models.ForeignKey('users.PFBUser',
                                   related_name='%(app_label)s_%(class)s_related+',
                                   on_delete=models.PROTECT)
    modified_by = models.ForeignKey('users.PFBUser',
                                    related_name='%(app_label)s_%(class)s_related+',
                                    on_delete=models.PROTECT)

    class Meta:
        abstract = True
