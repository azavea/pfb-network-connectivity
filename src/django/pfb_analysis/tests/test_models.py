from __future__ import division
import logging
import os

from django.contrib.gis.gdal import DataSource
from django.contrib.gis.geos import LineString
from django.test import override_settings, SimpleTestCase, TestCase

from pfb_analysis.models import (
    simplify_geom,
    AnalysisBatch,
    AnalysisJob,
    SIMPLIFICATION_MIN_VALID_AREA_RATIO,
    Neighborhood
)
from users.models import PFBUser

logger = logging.getLogger(__name__)

TESTDATA_PATH = os.path.join(os.path.dirname(__file__), 'data')


class SimplifyGeomTestCase(SimpleTestCase):

    def _test_simplify_geom_from_shpfile(self, shpfile_name):
        ds = DataSource(shpfile_name)
        self.assertEqual(len(ds), 1)
        layer = ds[0]
        self.assertEqual(len(layer), 1)
        geom = layer[0].geom.geos
        self._test_simplify_geom(geom)

    def _test_simplify_geom(self, geom):
        simple = simplify_geom(geom)
        self.assertLess(simple.num_coords, geom.num_coords)
        self.assertGreater(simple.area / geom.area, SIMPLIFICATION_MIN_VALID_AREA_RATIO)

    def test_polygon_geom_simplify_tolerance_more(self):
        """This tests a basic boundary, with a single, simple polygon.

        It should simplify ok using the first MORE tolerance and not require preserve_topology.

        """
        shpfile_name = os.path.join(TESTDATA_PATH, 'birmingham', 'birmingham.shp')
        self._test_simplify_geom_from_shpfile(shpfile_name)

    def test_polygon_geom_simplify_requires_preserve_topology(self):
        """This tests a more complex boundary, with a single, simple multi polygon.

        This is a multipolygon, where one polygon is much smaller than the other, which
        breaks our simplification tolerances and thus should require preserve_topology.

        """
        shpfile_name = os.path.join(TESTDATA_PATH, 'ann-arbor-mi', 'ann-arbor-mi.shp')
        self._test_simplify_geom_from_shpfile(shpfile_name)

    def test_not_a_polygon(self):
        geom = LineString(((0, 0), (1, 1)), srid=4326)
        self.assertEqual(geom, simplify_geom(geom))


@override_settings(DEFAULT_FILE_STORAGE='django.core.files.storage.FileSystemStorage')
class AnalysisBatchCreateFromShapefileTestCase(TestCase):

    def setUp(self):
        self.shapefile_path = os.path.join(TESTDATA_PATH,
                                           'batch_create_shapefile',
                                           'PFB_BigJumpCities_1.shp')
        self.shapefile_zip_path = os.path.join(TESTDATA_PATH,
                                               'batch_create_shapefile',
                                               'PFB_BigJumpCities_1.zip')

    def test_create_from_shapefile_path(self):
        batch = AnalysisBatch.objects.create_from_shapefile(self.shapefile_path)
        self.assertEqual(batch.jobs.count(), 6)

    def test_create_from_shapefile_http(self):
        url = 'https://s3.amazonaws.com/pfb-batch-run-inputs-us-east-1/PFB_BigJumpCities_1.zip'
        batch = AnalysisBatch.objects.create_from_shapefile(url)
        self.assertEqual(batch.jobs.count(), 6)

    def test_create_from_shapefile_zip(self):
        batch = AnalysisBatch.objects.create_from_shapefile(self.shapefile_zip_path)
        self.assertEqual(batch.jobs.count(), 6)

    def test_create_from_shapefile_no_submit(self):
        batch = AnalysisBatch.objects.create_from_shapefile(self.shapefile_path)
        self.assertEqual(batch.jobs.filter(status=AnalysisJob.Status.CREATED).count(), 6)

    def test_create_from_shapefile_submit(self):
        batch = AnalysisBatch.objects.create_from_shapefile(self.shapefile_path, submit=True)
        self.assertEqual(batch.jobs.filter(status=AnalysisJob.Status.QUEUED).count(), 6)

    def test_create_from_shapefile_with_user(self):
        root_user = PFBUser.objects.get_root_user()
        user = PFBUser.objects.create(email='user@peopleforbikes.org',
                                      organization=root_user.organization,
                                      created_by=root_user,
                                      modified_by=root_user)
        batch = AnalysisBatch.objects.create_from_shapefile(self.shapefile_path, user=user)
        self.assertEqual(batch.created_by.pk, user.pk)
        self.assertEqual(batch.modified_by.pk, user.pk)

    def test_create_from_shapefile_with_max_trip_distance(self):
        max_trip_dist = 2350
        batch = AnalysisBatch.objects.create_from_shapefile(
            self.shapefile_path,
            max_trip_distance=max_trip_dist
        )
        self.assertEqual(batch.jobs.last().max_trip_distance, max_trip_dist)

    def test_create_from_shapefile_without_max_trip_distance(self):
        # This is the only other place this number appears in the app code besides the
        # model field itself. So moving it into a settings variable just to share it
        # here seems like a lot.
        default_max_trip_distance = 2680
        batch = AnalysisBatch.objects.create_from_shapefile(self.shapefile_path)
        self.assertEqual(batch.jobs.last().max_trip_distance, default_max_trip_distance)

    def test_create_from_shapefile_not_filtering_on_created_user(self):
        """This tests the filtering logic for matching neighborhoods in a batch upload to ensure that neighborhoods are
        matched across batches, even if the existing neighborhood was created by a different user.

        """
        root_user = PFBUser.objects.get_root_user()

        ## Create batch with root user
        batch_1 = AnalysisBatch.objects.create_from_shapefile(self.shapefile_path, user=root_user)

        ## Confirm that only 6 neighborhoods exist
        self.assertEqual(Neighborhood.objects.all().count(), 6)

        ## Create a new user
        user = PFBUser.objects.create(email='user@peopleforbikes.org',
                                      organization=root_user.organization,
                                      created_by=root_user,
                                      modified_by=root_user)

        batch_2 = AnalysisBatch.objects.create_from_shapefile(self.shapefile_path, user=user)

        ## Confirm that only 6 neighborhoods exist, indicating that the neighborhoods in batch_2 were not created again
        self.assertEqual(Neighborhood.objects.all().count(), 6)

    def test_create_from_shapefile_not_filtering_on_fips_code(self):
        """This tests the filtering logic for matching neighborhoods in a batch upload to ensure that neighborhoods are
        matched across batches, even if an existing neighborhood has a FIPS code and the neighborhood in the batch doesn't.

        """
        root_user = PFBUser.objects.get_root_user()

        ## Create batch with root user
        batch_1 = AnalysisBatch.objects.create_from_shapefile(self.shapefile_path, user=root_user)

        ## Confirm that only 6 neighborhoods exist
        neighborhoods = Neighborhood.objects.all()
        self.assertEqual(neighborhoods.count(), 6)

        ## Add a fips_code to one of the neighborhoods
        n = neighborhoods[0]
        n.fips_code = '01040608'
        n.save()

        ## Create a new user
        user = PFBUser.objects.create(email='user@peopleforbikes.org',
                                      organization=root_user.organization,
                                      created_by=root_user,
                                      modified_by=root_user)

        batch_2 = AnalysisBatch.objects.create_from_shapefile(self.shapefile_path, user=user)

        ## Confirm that only 6 neighborhoods exist, indicating that the neighborhoods in the batch were matched with the existing recs
        self.assertEqual(Neighborhood.objects.all().count(), 6)
