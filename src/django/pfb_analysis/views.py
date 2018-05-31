from collections import OrderedDict
from datetime import datetime
import logging
import os
import shutil
import tempfile


from django.contrib.auth.models import AnonymousUser
from django.db import connection, DataError
from django.utils.text import slugify

from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import parsers, status
from rest_framework.decorators import detail_route, parser_classes
from rest_framework.exceptions import NotFound, APIException
from rest_framework.filters import OrderingFilter
from rest_framework.permissions import (AllowAny, IsAuthenticatedOrReadOnly)
from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet, ReadOnlyModelViewSet, ViewSet
from rest_framework.response import Response
import us

from pfb_network_connectivity.pagination import OptionalLimitOffsetPagination
from pfb_network_connectivity.filters import OrgAutoFilterBackend
from pfb_network_connectivity.permissions import IsAdminOrgAndAdminCreateEditOnly, RestrictedCreate

from .models import AnalysisBatch, AnalysisJob, AnalysisScoreMetadata, Neighborhood
from .serializers import (AnalysisJobSerializer,
                          AnalysisScoreMetadataSerializer,
                          NeighborhoodSerializer)
from .filters import AnalysisJobFilterSet


logger = logging.getLogger(__name__)


class AnalysisJobViewSet(ModelViewSet):
    """For listing or retrieving analysis jobs."""

    def get_queryset(self):
        queryset = AnalysisJob.objects.select_related('neighborhood').all()
        queryset = queryset.exclude(neighborhood__visibility=Neighborhood.Visibility.HIDDEN)
        if isinstance(self.request.user, AnonymousUser):
            queryset = queryset.filter(neighborhood__visibility=Neighborhood.Visibility.PUBLIC)
        return queryset

    serializer_class = AnalysisJobSerializer
    permission_classes = (RestrictedCreate, IsAuthenticatedOrReadOnly)
    filter_class = AnalysisJobFilterSet
    filter_backends = (DjangoFilterBackend, OrderingFilter, OrgAutoFilterBackend)
    ordering_fields = ('created_at', 'modified_at', 'overall_score', 'neighborhood__label',
                       'neighborhood__state_abbrev', 'population_total')
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
                ('tile_urls', job.tile_urls),
                ('overall_scores', job.overall_scores),
                ('overall_scores_url', job.overall_scores_url),
                ('score_inputs_url', job.score_inputs_url),
                ('ways_url', job.ways_url),
            ])
            return Response(results, status=status.HTTP_200_OK)
        else:
            return Response(None, status=status.HTTP_404_NOT_FOUND)


class AnalysisBatchViewSet(ViewSet):

    @parser_classes([parsers.MultiPartParser])
    def create(self, request, *args, **kwargs):
        """ Trigger a new analysis batch given a well-formatted shapefile

        Upload file to the 'file' key in a multipart form.

        Each polygon/multipolygon feature in the shapefile will have a neighborhood created
        for it if it doesn't exist, and the job for each neighborhood will immediately be submitted.

        Each feature in the shapefile should have a "city" and "state" attribute. The "city"
        attribute maps to Neighborhood.label and "state" maps to Neighborhood.state_abbrev.

        If the "city" and "state" of an uploaded feature matches an existing neighborhood,
        the existing one will be used and its geom updated with the one in the upload.

        """
        file_obj = request.data['file']
        tmpdir = tempfile.mkdtemp()
        try:
            # Awkward. create_from_shapefile opens with fiona, so we can't just directly pass
            #   in the file-like upload object. First we have to write it to disk, then pass
            #   the on-disk location to the create method instead.
            # Alternatively we could manually write to disk here, unzip and pass the fiona handle
            #   to create_from_shapefile, but that duplicates tested logic we do anyways within
            #   that method.
            upload_filename = os.path.join(tmpdir, 'upload.zip')
            with open(upload_filename, 'wb') as upload_file:
                upload_file.write(file_obj.read())

            try:
                batch = AnalysisBatch.objects.create_from_shapefile(upload_filename,
                                                                    submit=True,
                                                                    user=request.user)
            except Exception as e:
                # Errors are likely to be from bad input files, so send the exception message
                # back in an error response.
                raise APIException(e)

            # Rather than return the AnalysisBatch object which doesn't really have any useful
            # info of its own, serialize and return the list of newly created jobs.
            serializer = AnalysisJobSerializer(batch.jobs, many=True)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        finally:
            shutil.rmtree(tmpdir, ignore_errors=True)


class AnalysisScoreMetadataViewSet(ReadOnlyModelViewSet):
    """Convenience endpoint for available analysis score metadata"""

    queryset = AnalysisScoreMetadata.objects.all().order_by('priority')
    serializer_class = AnalysisScoreMetadataSerializer
    pagination_class = None
    filter_class = None
    permission_classes = (AllowAny,)


class NeighborhoodViewSet(ModelViewSet):
    """For listing or retrieving neighborhoods."""

    def get_queryset(self):
        queryset = Neighborhood.objects.select_related('organization').all()
        queryset = queryset.exclude(visibility=Neighborhood.Visibility.HIDDEN)
        if isinstance(self.request.user, AnonymousUser):
            queryset = queryset.filter(visibility=Neighborhood.Visibility.PUBLIC)
        return queryset

    permission_classes = (IsAdminOrgAndAdminCreateEditOnly, IsAuthenticatedOrReadOnly)
    filter_fields = ('organization', 'name', 'label', 'state_abbrev')
    filter_backends = (DjangoFilterBackend, OrderingFilter, OrgAutoFilterBackend)
    serializer_class = NeighborhoodSerializer
    pagination_class = OptionalLimitOffsetPagination
    ordering_fields = ('created_at',)

    def perform_create(self, serializer):
        if serializer.is_valid():
            serializer.save(organization=self.request.user.organization,
                            name=slugify(serializer.validated_data['label']))


class NeighborhoodBoundsGeoJsonViewList(APIView):
    """For retrieving all neighborhood bounds multipolygons as GeoJSON feature collection."""

    pagination_class = None
    filter_class = None
    permission_classes = (AllowAny,)

    def get(self, request, format=None, *args, **kwargs):
        query = """
        SELECT row_to_json(fc)
        FROM (
            SELECT 'FeatureCollection' AS type,
                array_to_json(array_agg(f)) AS features
            FROM (SELECT 'Feature' AS type,
                  ST_AsGeoJSON(g.geom_simple)::json AS geometry,
                  g.uuid AS id,
                  row_to_json((SELECT p FROM (
                    SELECT uuid AS id, name, label, state_abbrev, organization_id) AS p))
                    AS properties
            FROM pfb_analysis_neighborhood AS g WHERE g.visibility <> %s) AS f) AS fc;
        """

        with connection.cursor() as cursor:
            cursor.execute(query, [Neighborhood.Visibility.HIDDEN])
            json = cursor.fetchone()
            if not json or not len(json):
                return Response({})

        return Response(json[0])


class NeighborhoodBoundsGeoJsonViewDetail(APIView):
    """For retrieving a single neighborhood bound multipolygon as GeoJSON feature collection."""

    pagination_class = None
    filter_class = None
    permission_classes = (AllowAny,)

    def get(self, request, format=None, *args, **kwargs):
        query = """
        SELECT row_to_json(fc)
        FROM (
            SELECT 'FeatureCollection' AS type,
                array_to_json(array_agg(f)) AS features
            FROM (SELECT 'Feature' AS type,
                  ST_AsGeoJSON(g.geom_simple)::json AS geometry,
                  g.uuid AS id,
                  row_to_json((SELECT p FROM (
                    SELECT uuid AS id, name, label, state_abbrev, organization_id) AS p))
                    AS properties
            FROM pfb_analysis_neighborhood AS g WHERE g.uuid = %s) AS f) AS fc;
        """

        # get the neighborhood ID from the request
        uuid = kwargs.get('neighborhood', '')
        if not uuid:
            return Response({})

        try:
            with connection.cursor() as cursor:
                cursor.execute(query, [uuid])
                json = cursor.fetchone()
                if not json or not len(json):
                    return Response({})
        except DataError:
            raise NotFound(detail='{} is not a valid neighborhood UUID.'.format(uuid))

        return Response(json[0])


class NeighborhoodGeoJsonViewSet(APIView):
    """For retrieving all neighborhood centroids as GeoJSON feature collection."""

    pagination_class = None
    filter_class = None
    permission_classes = (AllowAny,)

    def get(self, request, format=None, *args, **kwargs):
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
            FROM pfb_analysis_neighborhood AS g WHERE g.visibility <> %s) AS f)  AS fc;
        """

        with connection.cursor() as cursor:
            cursor.execute(query, [Neighborhood.Visibility.HIDDEN])
            json = cursor.fetchone()
            if not json or not len(json):
                return Response({})

        return Response(json[0])


class USStateView(APIView):
    """Convenience endpoint for available U.S. state options."""

    pagination_class = None
    filter_class = None
    permission_classes = (AllowAny,)

    def get(self, request, format=None, *args, **kwargs):
        return Response([{'abbr': state.abbr, 'name': state.name} for state in us.STATES])
