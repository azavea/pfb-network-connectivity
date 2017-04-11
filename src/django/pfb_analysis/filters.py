import logging

from rest_framework import filters
import django_filters
from django.db.models import Case, When, Q, Max, Value, BooleanField

from .models import AnalysisJob


logger = logging.getLogger(__name__)


class AnalysisJobFilterSet(filters.FilterSet):
    """ Filters for AnalysisJob:
      - status, to handle job status being defined as a property and not as database field
      - latest, to return only the most recent analysis job for each neighborhood
    """

    status = django_filters.ChoiceFilter(choices=AnalysisJob.Status.CHOICES,
                                         method='filter_status')
    latest = django_filters.BooleanFilter(method='filter_latest')

    def filter_status(self, queryset, name, value):
        if value:
            matches = [m.pk for m in queryset.all() if m.status == value]
            queryset = queryset.filter(pk__in=matches)

        return queryset

    def filter_latest(self, queryset, name, value):
        if type(value) is bool:
            queryset = queryset.annotate(is_latest=Case(
                When(Q(created_at=Max('neighborhood__analysis_jobs__created_at')),
                     then=Value(True)),
                default=Value(False),
                output_field=BooleanField())).filter(is_latest=value)
        return queryset

    class Meta:
        model = AnalysisJob
        fields = ['neighborhood', 'batch', 'status', 'latest']
