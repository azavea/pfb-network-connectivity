import csv

from django.core.management.base import BaseCommand

from pfb_analysis.models import AnalysisJob


def load_default_speeds(job, city_csv_filename, state_csv_filename, output_csv_directory):

    def check_city_file_for_default_speed(csv_filename):
        speed = None
        """ Do some cleanup of the input row """
        with open(csv_filename, 'r') as csv_file:
            reader = csv.DictReader(csv_file)
            for row in reader:
                if str(row['fips_code_city']).strip().zfill(7) == str(job.neighborhood.city_fips).strip().zfill(7):
                    speed = int(row['speed'])
        return speed

    def check_state_file_for_default_speed(csv_filename):
        speed = None
        """ Do some cleanup of the input row """
        with open(csv_filename, 'r') as csv_file:
            reader = csv.DictReader(csv_file)
            for row in reader:
                if str(row['fips_code_state']) == str(job.neighborhood.city_fips)[:2]:
                    speed = int(row['speed'])
        return speed

    used_file = None
    default_speed_src = None

    default_speed = check_city_file_for_default_speed(city_csv_filename)
    if default_speed:
        # Default to city, if available
        used_file = city_csv_filename
        default_speed_src = 'City'
    else:
        # Fallback to state value if city default not available
        default_speed = check_state_file_for_default_speed(state_csv_filename)
        if default_speed:
            used_file = state_csv_filename
            default_speed_src = 'State'
        else:
            # Fallback to global default of 25 if state default not available
            default_speed = 25
            used_file = None

    print(default_speed)
    print(used_file)
    job.default_speed_limit = default_speed
    jr = {'default_speed': default_speed}
    if default_speed_src:
        job.speed_limit_src = default_speed_src
        jr['default_speed_src'] = default_speed_src
    else:
        jr['default_speed_src'] = 'Global default'

    fpath = '{}/{}'.format(output_csv_directory, 'default_speed.csv')
    with open(fpath, 'w') as ofile:
        c = csv.DictWriter(ofile, fieldnames=jr.keys())
        c.writeheader()
        c.writerow(jr)

    job.save()
    return job, used_file


class Command(BaseCommand):
    help = """ Load CSV default speeds output by the analysis into AnalysisJob.overall_scores

    Given input CSV, with option --key-column=score_name:

    id,score_name,category,score,notes
    1,'Total population low stress','Population',100000.0,'A long descriptive string'

    Converts to dict:
    {
        'Total population low stress': {
            'category': 'Population',
            'score': 100000.0,
            'notes': 'A long descriptive string'
        }
    }

    Note that if the column provided to --key-column is not unique, then values later in the table
    will overwrite older ones
    """

    def add_arguments(self, parser):
        parser.add_argument('job_uuid', type=str)
        parser.add_argument('--state_file', type=str,
                            help='Absolute path to state_speed csv to load')
        parser.add_argument('--city_file', type=str,
                            help='Absolute path to city_speed csv to load')
        parser.add_argument('--output_path', type=str,
                            help='Absolute path to folder to output default_speed.csv')

    def handle(self, *args, **options):
        job_uuid = options['job_uuid']
        state_csv = options['state_file']
        city_csv = options['city_file']
        output_path = options['output_path']

        try:
            job = AnalysisJob.objects.get(pk=job_uuid)
            job, used_file = load_default_speeds(job, city_csv, state_csv, output_path)
            if used_file:
                self.stdout.write('{}: Loaded default_speed of {} from {} level file {}'.format(job, job.default_speed_limit, job.speed_limit_src, used_file))
            else:
                self.stdout.write('{}: Loaded default_speed of {} from global default'.format(job, job.default_speed_limit))
        except (AnalysisJob.DoesNotExist, ValueError, KeyError):
            print('WARNING: Tried to update default_speed for invalid job {} ')
            raise
