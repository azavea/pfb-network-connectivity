from django.core.management.base import BaseCommand

from pfb_analysis.models import AnalysisJob


class Command(BaseCommand):
    help = "Update status during an analysis job"

    def add_arguments(self, parser):
        # Positional arguments
        parser.add_argument('job_id')
        parser.add_argument('status')
        parser.add_argument('step')
        parser.add_argument('message', nargs='?', default='')

    def handle(self, *args, **options):
        try:
            job = AnalysisJob.objects.get(pk=options['job_id'])
        except (AnalysisJob.DoesNotExist, ValueError, KeyError):
            print('WARNING: Tried to update status for invalid job {job_id} '
                  '(to {status} {step})'.format(**options))
        else:
            job.update_status(options['status'], step=options['step'], message=options['message'])
