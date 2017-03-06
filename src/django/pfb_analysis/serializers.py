from pfb_analysis.models import AnalysisJob
from pfb_network_connectivity.serializers import PFBModelSerializer


class AnalysisJobSerializer(PFBModelSerializer):

    class Meta:
        model = AnalysisJob
