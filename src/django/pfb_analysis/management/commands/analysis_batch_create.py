from django.core.management.base import BaseCommand

from pfb_analysis.models import AnalysisBatch
from users.models import PFBUser


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
        parser.add_argument('--user', default=None, type=str)
        parser.add_argument('--submit', action='store_true',
                            help='Automatically submit jobs after creation')

    def handle(self, *args, **options):
        shapefile_url = options['shapefile_url']

        if options['user'] is not None:
            user = PFBUser.objects.get(email=options['user'])
        else:
            user = PFBUser.objects.get_root_user()

        AnalysisBatch.objects.create_from_shapefile(shapefile_url,
                                                    user=user,
                                                    submit=options['submit'])
