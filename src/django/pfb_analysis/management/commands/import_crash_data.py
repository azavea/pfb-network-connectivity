from django.conf import settings
from django.contrib.gis.geos import Point
from django.core.management.base import BaseCommand
from django.db import transaction

import boto3
import csv
import logging
import os
import shutil
import tempfile
import zipfile

from pfb_analysis.models import Crash


logger = logging.getLogger(__name__)

def download_csv():
    tmpdir = tempfile.mkdtemp()
    zipfile_path = os.path.join(tmpdir, "crashes.zip")
    s3_client = boto3.client('s3')
    s3_client.download_file(settings.AWS_STORAGE_BUCKET_NAME,
                            "data/crashes.zip",
                            zipfile_path)
    with zipfile.ZipFile(zipfile_path, "r") as zip_ref:
        zip_ref.extractall(tmpdir)
    return os.path.join(tmpdir, "crashes.csv")

def get_fatality_type(type):
    if type == 'active': return 'ACTIVE'
    elif type == 'bike': return 'BIKE'
    elif type == 'mv': return 'MOTOR_VEHICLE'
    else: raise Exception('Fatality type not found')

@transaction.atomic
def import_csv(csv_filename):
    import_tmpdir = ''
    try:
        csv_path = download_csv()
        # Clear existing geometries, in case this is a re-import
        Crash.objects.all().delete()

        with open(csv_path, 'r') as csv_file:
            reader = csv.DictReader(csv_file)
            for row in reader:
                crash = Crash.objects.create(
                    fatality_count=row['FATALS'],
                    fatality_type=get_fatality_type(row['fatal_typ']),
                    geom_pt=Point(float(row['LONGITUD']), float(row['LATITUDE'])),
                    year=row['YEAR'],
                    )

    except Exception as err:
        logger.exception('Error importing crash csv')
        raise err
    finally:
        if import_tmpdir:
            shutil.rmtree(import_tmpdir, ignore_errors=True)

class Command(BaseCommand):
    help = """ Load crashes from csv in s3 """

    def handle(self, *args, **options):
        csv_filename = 'crashes.csv'

        try:
            import_csv(csv_filename)
            self.stdout.write('Loaded crashes from {}'.format(csv_filename))
        except (ValueError, KeyError):
            print('WARNING: Tried to update crashes from file {}'.format(csv_filename))
            raise
