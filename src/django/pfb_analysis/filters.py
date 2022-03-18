import logging

from django.db.models import Q

from django_filters import rest_framework as filters
import django_filters

from .models import AnalysisJob, Neighborhood


logger = logging.getLogger(__name__)


class AnalysisJobFilterSet(filters.FilterSet):
    """ Filters for AnalysisJob:
      - status, to handle job status being defined as a property and not as database field
      - latest, to return only the most recent analysis job for each neighborhood
    """

    latest = django_filters.BooleanFilter(method='filter_latest')
    search = django_filters.CharFilter(method='filter_search')
    status = django_filters.ChoiceFilter(choices=AnalysisJob.Status.CHOICES)

    def filter_latest(self, queryset, name, value):
        """ Return latest successful analysis for each neighborhood, but falls back
        to the latest modified if there are no successful analysis jobs for a neighborhood.

        This means that if it's applied on top of a status filter, it follows the fallback
        path and returns the latest job with the given status.

        Pre-fetches related neighborhoods to reduce queries during serialization.
        """
        if type(value) is bool:
            queryset = queryset.filter(last_job_neighborhood__isnull=(not value))

        return queryset

    def filter_search(self, queryset, name, value):
        return queryset.filter(Q(neighborhood__label__icontains=value) |
                               Q(neighborhood__country__icontains=value) |
                               Q(neighborhood__state_abbrev__icontains=value))

    class Meta:
        model = AnalysisJob
        fields = {'neighborhood': ['exact', 'in'],
                  'neighborhood__name': ['exact', 'contains'],
                  'neighborhood__label': ['exact', 'contains'],
                  'neighborhood__country': ['exact'],
                  'neighborhood__state_abbrev': ['exact'],
                  'neighborhood__city_fips': ['exact'],
                  'batch': ['exact', 'in'],
                  'status': ['exact'],
                  'latest': ['exact']}


class NeighborhoodFilterSet(filters.FilterSet):
    """ Filters for Neighborhood:
      - city, find by name
      - state, find by state
      - country, find by country
    """

    name = django_filters.CharFilter(method='city_search')
    state = django_filters.CharFilter(method='state_search')
    country = django_filters.CharFilter(method='country_search')


    def city_search(self, queryset, name, value):
        return queryset.filter(Q(label__icontains=value))

    def state_search(self, queryset, name, value):
        return queryset.filter(Q(state_abbrev__icontains=value))

    def country_search(self, queryset, name, value):
        return queryset.filter(Q(country__icontains=value))

    class Meta:
        model = Neighborhood
        fields = {'name': ['exact', 'icontains'],
                  'label': ['exact', 'icontains'],
                  'organization': ['exact'],
                  'country': ['exact', 'icontains', 'in'],
                  'state_abbrev': ['exact', 'icontains', 'in']}