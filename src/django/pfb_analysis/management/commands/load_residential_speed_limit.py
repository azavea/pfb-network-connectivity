import csv

from django.core.management.base import BaseCommand

from pfb_analysis.models import AnalysisJob


def load_speed_limit(job, csv_filename):
    with open(csv_filename, 'r') as csv_file:
        reader = csv.DictReader(csv_file)
        row = next(reader)
    # Take the city value if there is one, or fall back to the state value.
    # In both cases check for truthiness, since a missing value will come back as zero
    if row.get("city_speed"):
        job.default_speed_limit = row["city_speed"]
        job.speed_limit_src = AnalysisJob.SpeedLimitSource.CITY
    elif row.get("state_speed"):
        job.default_speed_limit = row["state_speed"]
        job.speed_limit_src = AnalysisJob.SpeedLimitSource.STATE
    job.save()


class Command(BaseCommand):
    help = """ Load 'residential_speed_limit.csv' produced by the analysis into
    AnalysisJob.default_speed_limit

    Expected CSV format: one line, with state and city FIPS codes and speeds.
    The city code and speed can be blank.

    state_fips_code,city_fips_code,state_speed,city_speed
    24,2404000,30,25

    Saves the city speed limit if present, otherwise the state limit.
    """

    def add_arguments(self, parser):
        parser.add_argument('job_uuid', type=str)
        parser.add_argument('csv_file', type=str,
                            help='Absolute path to residential speed limit csv to load')

    def handle(self, *args, **options):
        job_uuid = options['job_uuid']
        csv_filename = options['csv_file']

        try:
            job = AnalysisJob.objects.get(pk=job_uuid)
        except (AnalysisJob.DoesNotExist):
            print('WARNING: Tried to set default_speed_limit for invalid job {} '
                  'from file {}'.format(job_uuid, csv_filename))
            raise
        load_speed_limit(job, csv_filename)
        self.stdout.write('{}: Loaded default_speed_limit from {}'.format(job, csv_filename))
