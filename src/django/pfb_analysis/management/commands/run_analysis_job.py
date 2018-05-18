from django.core.management.base import BaseCommand

from pfb_analysis.models import AnalysisJob, Neighborhood
from users.models import PFBUser


class Command(BaseCommand):
    help = """ Create and run an AnalysisJob for the given neighborhood

    The neighborhood name must match an existing Neighborhood for the user's organization.

    """

    def add_arguments(self, parser):
        # Positional arguments
        parser.add_argument('neighborhood')
        parser.add_argument('--user', default=None, type=str)

    def handle(self, *args, **options):
        if options['user'] is not None:
            user = PFBUser.objects.get(email=options['user'])
        else:
            user = PFBUser.objects.get_root_user()
        neighborhood = Neighborhood.objects.get(name=options['neighborhood'],
                                                organization=user.organization)
        job = AnalysisJob.objects.create(neighborhood=neighborhood,
                                         created_by=user,
                                         modified_by=user)
        job.run()
        self.stdout.write('Started job {} for {}'.format(job.batch_job_id, neighborhood.name))
