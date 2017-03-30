from django.core.management.base import BaseCommand
from django.core.exceptions import FieldDoesNotExist

from pfb_analysis.models import AnalysisJob


class Command(BaseCommand):
    help = "Update an attribute of an analysis job"

    def add_arguments(self, parser):
        # Positional arguments
        parser.add_argument('job_id')
        parser.add_argument('attr')
        parser.add_argument('value')

    def handle(self, *args, **options):
        """ Try to set the attribute on the job.
        Invalid job ID warns, any other error raises """
        try:
            qs = AnalysisJob.objects.filter(pk=options['job_id'])
            # Force qs evaluation to catch invalid job_id errors
            qs.exists()
        except (ValueError, AnalysisJob.DoesNotExist):
            print ("WARNING: Tried to update attribute '{attr}' "
                   "for invalid job {job_id}.".format(**options))
        else:
            try:
                qs.update(**{options['attr']: options['value']})
            except (FieldDoesNotExist, ValueError, TypeError):
                print ("Error trying to update attribute '{attr}' to '{value}' "
                       "for {job_id}.".format(**options))
                raise
            else:
                self.stdout.write("{job_id}: Set '{attr}' to '{value}'".format(**options))
