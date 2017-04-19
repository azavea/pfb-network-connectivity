import json
import os
import shutil
import tempfile
import zipfile

import fiona
import requests

from django.contrib.auth import get_user_model
from django.contrib.gis.geos import GEOSGeometry
from django.core.management.base import BaseCommand

from pfb_analysis.models import AnalysisBatch, AnalysisJob, Neighborhood


def download_file(url, local_filename=None):
    if not local_filename:
        local_filename = os.path.join('.', url.split('/')[-1])
    r = requests.get(url, stream=True)
    with open(local_filename, 'wb') as f:
        for chunk in r.iter_content(chunk_size=1024):
            if chunk:  # filter out keep-alive new chunks
                f.write(chunk)
    return local_filename


class Command(BaseCommand):
    help = """ Create a new AnalysisBatch based on the input shapefile

    A new analysis job is created for each Polygon/MultiPolygon feature in the shapefile.
    Each feature must have the following attributes:
    - Name: The name of the boundary
    - State: The 2-letter state abbreviation code that the boundary is contained within

    If --submit is provided, the jobs are automatically submitted after creation

    """

    def add_arguments(self, parser):
        parser.add_argument('shapefile_url', type=str)
        parser.add_argument('--user', default='systems+pfb@azavea.com', type=str)
        parser.add_argument('--submit', action='store_true',
                            help='Automatically submit jobs after creation')

    def handle(self, *args, **options):
        shapefile_url = options['shapefile_url']

        User = get_user_model()
        user = User.objects.get(email=options['user'])

        batch = AnalysisBatch.objects.create(created_by=user, modified_by=user)

        try:
            tmpdir = tempfile.mkdtemp()
            self.stdout.write('Using temp dir: {}'.format(tmpdir))

            # Extract download zipfile and find shp filename
            local_zipfile = os.path.join(tmpdir, 'boundary.zip')
            download_file(shapefile_url, local_zipfile)
            with zipfile.ZipFile(local_zipfile) as zip:
                files = zip.namelist()
                zip.extractall(tmpdir)
                local_shapefile = next(filename for filename in files if filename.endswith('.shp'))
            local_shapefile = os.path.join(tmpdir, local_shapefile)

            # Open shp and trigger analysis job for each feature in layer
            self.stdout.write('Opening shapefile: {}'.format(local_shapefile))
            with fiona.open(local_shapefile, 'r') as source:
                for feature in source:
                    city = feature['properties']['city']
                    state = feature['properties']['state']
                    osm_extract_url = feature['properties'].get('osm_url', None)
                    label = '{}, {}'.format(city, state)
                    name = Neighborhood.name_for_label(label)

                    # Get or create neighborhood for feature
                    neighborhood_dict = {
                        'name': name,
                        'label': label,
                        'state_abbrev': state,
                        'organization': user.organization,
                        'created_by': user,
                        'modified_by': user,
                    }
                    geom = GEOSGeometry(json.dumps(feature['geometry']))
                    try:
                        neighborhood = Neighborhood.objects.get(**neighborhood_dict)
                    except Neighborhood.DoesNotExist:
                        neighborhood = Neighborhood(**neighborhood_dict)
                        self.stdout.write('CREATED: {}'.format(neighborhood))

                    neighborhood.set_boundary_file(geom)
                    neighborhood.save()

                    # Create new job
                    job = AnalysisJob.objects.create(neighborhood=neighborhood,
                                                     batch=batch,
                                                     osm_extract_url=osm_extract_url,
                                                     created_by=user,
                                                     modified_by=user)
                    self.stdout.write('ID: {} -- {}'.format(str(job.uuid), str(job)))
            self.stdout.write('Batch created: {}'.format(str(batch)))
        except Exception:
            # If job creation failed, delete the batch
            batch.delete()
            raise
        finally:
            self.stdout.write('Removing temporary files...')
            shutil.rmtree(tmpdir, ignore_errors=True)

        if options['submit']:
            self.stdout.write('Starting all jobs...')
            batch.submit()
            self.stdout.write('Started {} jobs.'.format(batch.jobs.count()))
