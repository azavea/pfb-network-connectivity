# -*- coding: utf-8 -*-
# Generated by Django 1.11.13 on 2018-11-20 15:54
from __future__ import unicode_literals

import logging
import os
import shutil
import tempfile
import zipfile

import boto3

from django.conf import settings
from django.contrib.gis.gdal import DataSource
# gdal importer geometries are gdal.geometries types; Django uses gis.geos types for models
from django.contrib.gis.gdal import geometries
from django.contrib.gis import geos
from django.db import migrations

logger = logging.getLogger(__name__)


def geom_from_results_url(shapefile_key):
    """ Downloads shapefile from given URL and returns its geometry

    No explicit error handling/logging, will raise original exception if failure
    """
    geom = None
    logger.info(shapefile_key)
    logger.info('importing results back from shapefile: {sfile}'.format(sfile=shapefile_key))
    try:
        tmpdir = tempfile.mkdtemp()
        local_zipfile = os.path.join(tmpdir, 'shapefile.zip')
        s3_client = boto3.client('s3')
        s3_client.download_file(settings.AWS_STORAGE_BUCKET_NAME,
                                shapefile_key,
                                local_zipfile)
        with zipfile.ZipFile(local_zipfile, 'r') as zip_handle:
            zip_handle.extractall(tmpdir)
        shpfiles = [filename for filename in os.listdir(tmpdir) if filename.endswith('shp')]
        shp_filename = os.path.join(tmpdir, shpfiles[0])
        datasource = DataSource(shp_filename)
        layer = datasource[0]
        geoms = layer.get_geoms(geos=True)

        # Make multi type geometry from collection of simple types
        if type(geoms[0]) == geos.LineString:
            geom = geos.MultiLineString(geoms)
        else:
            # Make a multipolygon from the collection of geometries provided.
            polygons = []
            for g in geoms:
                if type(g) == geos.Polygon:
                    polygons.append(g)
                else:
                    for gg in g:
                        polygons.append(gg)

            geom = geos.MultiPolygon(polygons)
    except:
        geom = None
        logger.exception('ERROR: {}'.format(str(shapefile_key)))
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)
    return geom


def s3_job_url(job, filename):
    return 'results/{uuid}/{filename}'.format(uuid=job.uuid, filename=filename)


def add_results_geoms(apps, schema_editor):
    AnalysisJob = apps.get_model('pfb_analysis', 'AnalysisJob')
    for job in AnalysisJob.objects.all():
        job.neighborhood_ways_geom = geom_from_results_url(s3_job_url(job, 'neighborhood_ways.zip'))
        job.census_blocks_geom = geom_from_results_url(s3_job_url(job,
                                                                  'neighborhood_census_blocks.zip'))
        job.save()


class Migration(migrations.Migration):

    dependencies = [
        ('pfb_analysis', '0031_auto_20181120_1554'),
    ]

    operations = [
        migrations.RunPython(add_results_geoms, reverse_code=migrations.RunPython.noop)
    ]
