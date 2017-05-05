from collections import OrderedDict
from datetime import datetime

import us

from django.db import connection
from django.utils.text import slugify

from rest_framework import status
from rest_framework.decorators import detail_route
from rest_framework.filters import DjangoFilterBackend, OrderingFilter
from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet, ReadOnlyModelViewSet
from rest_framework.response import Response

from pfb_network_connectivity.pagination import OptionalLimitOffsetPagination
from pfb_network_connectivity.filters import OrgAutoFilterBackend
from pfb_network_connectivity.permissions import IsAdminOrgAndAdminCreateEditOnly, RestrictedCreate

from .models import AnalysisJob, Neighborhood
from .serializers import (AnalysisJobSerializer,
                          NeighborhoodSerializer,
                          NeighborhoodGeoJsonSerializer,
                          NeighborhoodBoundsGeoJsonSerializer)
from .filters import AnalysisJobFilterSet


class AnalysisJobViewSet(ModelViewSet):
    """For listing or retrieving analysis jobs."""

    queryset = AnalysisJob.objects.all()
    serializer_class = AnalysisJobSerializer
    permission_classes = (RestrictedCreate,)
    filter_class = AnalysisJobFilterSet
    filter_backends = (DjangoFilterBackend, OrderingFilter, OrgAutoFilterBackend)
    ordering_fields = ('created_at', 'modified_at', 'overall_score', 'neighborhood__label',
                       'neighborhood__state_abbrev')
    ordering = ('-created_at',)

    def perform_create(self, serializer):
        """ Start analysis jobs as soon as created """
        instance = serializer.save()
        instance.run()

    @detail_route(methods=['post'])
    def cancel(self, request, pk=None):
        job = self.get_object()
        job.cancel(reason='AnalysisJob terminated via API by {} at {}'
                          .format(request.user.email, datetime.utcnow()))
        serializer = AnalysisJobSerializer(job)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @detail_route(methods=['GET'])
    def results(self, request, pk=None):
        job = self.get_object()

        if job.status == AnalysisJob.Status.COMPLETE:
            results = OrderedDict([
                ('census_block_count', job.census_block_count),
                ('census_blocks_url', job.census_blocks_url),
                ('connected_census_blocks_url', job.connected_census_blocks_url),
                ('destinations_urls', job.destinations_urls),
                ('overall_scores', job.overall_scores),
                ('overall_scores_url', job.overall_scores_url),
                ('score_inputs_url', job.score_inputs_url),
                ('ways_url', job.ways_url),
            ])
            return Response(results, status=status.HTTP_200_OK)
        else:
            return Response(None, status=status.HTTP_404_NOT_FOUND)


class NeighborhoodMixin(APIView):
    """Shared properties of the neighborhood viewsets."""

    queryset = Neighborhood.objects.all()
    permission_classes = (IsAdminOrgAndAdminCreateEditOnly,)
    filter_fields = ('organization', 'name', 'label', 'state_abbrev')
    filter_backends = (DjangoFilterBackend, OrderingFilter, OrgAutoFilterBackend)


class NeighborhoodViewSet(NeighborhoodMixin, ModelViewSet):
    """For listing or retrieving neighborhoods."""

    serializer_class = NeighborhoodSerializer
    pagination_class = OptionalLimitOffsetPagination
    ordering_fields = ('created_at',)

    def perform_create(self, serializer):
        if serializer.is_valid():
            serializer.save(organization=self.request.user.organization,
                            name=slugify(serializer.validated_data['label']))


class NeighborhoodBoundsGeoJsonViewSet(NeighborhoodMixin, ReadOnlyModelViewSet):
    """For retrieving neighborhood bounds multipolygon as GeoJSON feature collection."""

    serializer_class = NeighborhoodBoundsGeoJsonSerializer
    pagination_class = None


class NeighborhoodGeoJsonViewSet(APIView):
    """For retrieving all neighborhood centroids as GeoJSON feature collection."""

    def get(self, request, format=None):
        """
        Uses raw query for fetching as GeoJSON because it is much faster to let PostGIS generate
        than Djangonauts serializer.
        """
        query = """
        SELECT row_to_json(fc)
        FROM (
            SELECT 'FeatureCollection' AS type,
                array_to_json(array_agg(f)) AS features
            FROM (SELECT 'Feature' AS type, ST_AsGeoJSON(g.geom_pt)::json AS geometry, g.uuid AS id,
                  row_to_json((SELECT p FROM (
                    SELECT uuid AS id, name, label, state_abbrev, organization_id) AS p))
                    AS properties
            FROM pfb_analysis_neighborhood AS g) AS f)  AS fc;
        """

        with connection.cursor() as cursor:
            cursor.execute(query)
            json = cursor.fetchone()
            if not json or not len(json):
                return Response({})

        return Response(json[0])


class USStateView(APIView):
    """Convenience endpoint for available U.S. state options."""

    def get(self, request, format=None):
        return Response([{'abbr': state.abbr, 'name': state.name} for state in us.STATES])
