import logging

from rest_framework import filters
import django_filters

from .models import AnalysisJob, AnalysisJobStatusUpdate, Neighborhood


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
        """ Filters down to the latest successful analysis for each neighborhood, but falls back
        to the latest modified if there are no successful analysis jobs for a neighborhood.

        This means that if it's applied on top of a status filter, it follows the fallback
        path and returns the latest job with the given status.

        Runs tons of queries, but the query expression required to do this would be gnarly.
        """
        if type(value) is bool:
            matches = set()
            initial_job_set = queryset.all()
            neighborhood_ids = set(job.neighborhood_id for job in initial_job_set)
            for neighborhood in Neighborhood.objects.filter(pk__in=neighborhood_ids):
                status_set = AnalysisJobStatusUpdate.objects.filter(
                    job__neighborhood=neighborhood,
                    job__in=initial_job_set)
                success_set = status_set.filter(status=AnalysisJob.Status.SUCCESS_STATUS)
                if success_set.exists():
                    status_set = success_set
                if status_set.exists():
                    matches.add(status_set.latest('timestamp').job.pk)
                else:
                    matches.add(neighborhood.analysis_jobs.latest('modified_at').pk)
            if value is True:
                queryset = queryset.filter(pk__in=matches)
            else:
                queryset = queryset.exclude(pk__in=matches)

        return queryset

    class Meta:
        model = AnalysisJob
        fields = {'neighborhood': ['exact', 'in'],
                  'neighborhood__name': ['exact', 'contains'],
                  'neighborhood__label': ['exact', 'contains'],
                  'batch': ['exact', 'in'],
                  'status': ['exact'],
                  'latest': ['exact']}
