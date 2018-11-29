from django.core.management.base import BaseCommand

import logging
import os
import shutil
import tempfile
import zipfile

import boto3

from django.conf import settings
from django.contrib.gis.utils import LayerMapping
from django.core.exceptions import ValidationError

from pfb_analysis.models import AnalysisJob, CensusBlocksResults, NeighborhoodWaysResults

logger = logging.getLogger(__name__)


CENSUS_BLOCK_LAYER_MAPPING = {
    'geom': 'POLYGON',
    'overall_score': 'OVERALL_SC',
    'job': { 'uuid': 'JOB_ID' },
}

NEIGHBORHOOD_WAYS_LAYER_MAPPING = {
    'geom': 'LINESTRING',
    'tf_seg_str': 'TF_SEG_STR',
    'ft_seg_str': 'FT_SEG_STR',
    'xwalk': 'XWALK',
    'ft_bike_in': 'FT_BIKE_IN',
    'tf_bike_in': 'TF_BIKE_IN',
    'functional': 'FUNCTIONAL',
    'job': { 'uuid': 'JOB_ID' },
}


def geom_from_results_url(shapefile_key):
    """ Downloads and extracts a zipped shapefile and returns the containing temporary directory.
    """
    logger.info('Importing results back from shapefile: {sfile}'.format(sfile=shapefile_key))
    tmpdir = tempfile.mkdtemp()
    local_zipfile = os.path.join(tmpdir, 'shapefile.zip')
    s3_client = boto3.client('s3')
    s3_client.download_file(settings.AWS_STORAGE_BUCKET_NAME,
                            shapefile_key,
                            local_zipfile)
    with zipfile.ZipFile(local_zipfile, 'r') as zip_handle:
        zip_handle.extractall(tmpdir)
    return tmpdir


def s3_job_url(job, filename):
    return 'results/{uuid}/{filename}'.format(uuid=job.uuid, filename=filename)


def add_results_geoms(job):
    blocks_tmpdir = ''
    ways_tmpdir = ''
    try:
        blocks_tmpdir = geom_from_results_url(s3_job_url(job, 'neighborhood_census_blocks.zip'))
        block_shpfiles = [filename for filename in
                          os.listdir(blocks_tmpdir) if filename.endswith('shp')]
        blocks_file = os.path.join(blocks_tmpdir, block_shpfiles[0])
        blocks_layer_map = LayerMapping(CensusBlocksResults,
                                        blocks_file,
                                        CENSUS_BLOCK_LAYER_MAPPING)
        blocks_layer_map.save()
        CensusBlocksResults.objects.filter(job=None).update(job=job)

        ways_tmpdir = geom_from_results_url(s3_job_url(job, 'neighborhood_ways.zip'))
        ways_shpfiles = [filename for filename in
                         os.listdir(ways_tmpdir) if filename.endswith('shp')]
        ways_file = os.path.join(ways_tmpdir, ways_shpfiles[0])
        ways_layer_map = LayerMapping(NeighborhoodWaysResults,
                                      ways_file,
                                      NEIGHBORHOOD_WAYS_LAYER_MAPPING)
        ways_layer_map.save()
        NeighborhoodWaysResults.objects.filter(job=None).update(job=job)
    except:
        logger.exception('Error importing results shapefiles for job: {}'.format(str(job.uuid)))
    finally:
        if blocks_tmpdir:
            shutil.rmtree(blocks_tmpdir, ignore_errors=True)
        if ways_tmpdir:
            shutil.rmtree(ways_tmpdir, ignore_errors=True)


class Command(BaseCommand):
    help = """Import back results and geometries from exported shapefiles for an analysis job.

    If job UUID not specified, will run for all analysis jobs.
    """

    def add_arguments(self, parser):
        # Positional arguments
        parser.add_argument('job_id', nargs='?')

    def handle(self, *args, **options):
        try:
            job_id = options['job_id']
            if job_id:
                job = AnalysisJob.objects.get(pk=job_id)
                logger.info('Running import for analysis job {job_id}.'.format(job_id=job.uuid))
                add_results_geoms(job)
            else:
                logger.info('Running import for all analysis jobs.')
                for job in AnalysisJob.objects.all():
                    add_results_geoms(job)
        except (AnalysisJob.DoesNotExist, ValueError, KeyError, ValidationError):
            logger.exception('ERROR: Tried to re-import results for invalid job UUID '
                             '{job_id}'.format(**options))
