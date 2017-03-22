from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

from pfb_analysis.models import AnalysisJob, Neighborhood


class Command(BaseCommand):
    help = """ Create and run an AnalysisJob for the given neighborhood

    The neighborhood name must match an existing Neighborhood for the user's organization.

    """

    def add_arguments(self, parser):
        # Positional arguments
        parser.add_argument('neighborhood')
        parser.add_argument('--user', default='systems+pfb@azavea.com', type=str)

    def handle(self, *args, **options):
        UserModel = get_user_model()
        user = UserModel.objects.get(email=options['user'])
        neighborhood = Neighborhood.objects.get(name=options['neighborhood'],
                                                organization=user.organization)
        job = AnalysisJob.objects.create(neighborhood=neighborhood,
                                         created_by=user,
                                         modified_by=user)
        job.run()
        self.stdout.write('Started jobs {} for {}'.format(job.batch_job_id, neighborhood.name))
