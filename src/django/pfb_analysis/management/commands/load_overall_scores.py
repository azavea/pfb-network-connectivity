import csv

from django.core.management.base import BaseCommand

from pfb_analysis.models import AnalysisJob


class Command(BaseCommand):
    help = """ Load CSV scores output by the analysis into AnalysisJob.overall_scores

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
        parser.add_argument('csv_file', type=str,
                            help='Absolute path to overall scores csv to load')
        parser.add_argument('--key-column', type=str, default='score_name',
                            help='Column name to use for score key in results dict')

    def handle(self, *args, **options):
        job_uuid = options['job_uuid']
        csv_filename = options['csv_file']
        key_column = options['key_column']

        try:
            job = AnalysisJob.objects.get(pk=job_uuid)
        except (AnalysisJob.DoesNotExist, ValueError, KeyError):
            print('WARNING: Tried to update overall_scores for invalid job {} '
                  'from file {}'.format(job_uuid, csv_filename))
            return

        with open(csv_filename, 'r') as csv_file:
            reader = csv.DictReader(csv_file)
            results = {}
            for row in reader:
                key_column_value = row.pop(key_column)
                metric = self.clean_metric_dict(row.copy())
                results[key_column_value] = metric
        job.overall_scores = results
        job.save()
        self.stdout.write('{}: Loaded overall_scores from {}'.format(job, csv_filename))

    def clean_metric_dict(self, metric):
        """ Do some cleanup of the input row """
        del metric['id']
        # Attempt to convert numeric values in row to float type
        for k, v in metric.iteritems():
            try:
                metric[k] = float(v)
            except ValueError:
                pass
        return metric
