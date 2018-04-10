import os

from django.contrib.gis.gdal import DataSource
from django.contrib.gis.geos import LineString
from django.test import SimpleTestCase

from pfb_analysis.models import simplify_geom, SIMPLIFICATION_MIN_VALID_AREA_RATIO

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
