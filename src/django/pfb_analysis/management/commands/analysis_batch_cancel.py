from django.core.management.base import BaseCommand

from pfb_analysis.models import AnalysisBatch


class Command(BaseCommand):
    help = """ Cancel all jobs in an AnalysisBatch """

    def add_arguments(self, parser):
        parser.add_argument('batch_uuid', type=str)

    def handle(self, *args, **options):
        batch_uuid = options['batch_uuid']

        batch = AnalysisBatch.objects.get(uuid=batch_uuid)
        self.stdout.write('Cancelling {}'.format(batch))
        batch.cancel()
