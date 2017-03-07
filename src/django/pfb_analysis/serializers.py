from pfb_analysis.models import AnalysisJob, Neighborhood
from pfb_network_connectivity.serializers import PFBModelSerializer


class AnalysisJobSerializer(PFBModelSerializer):

    class Meta:
        model = AnalysisJob
        fields = '__all__'
        read_only_fields = ('uuid', 'created', 'created_by', 'modified_by')


class NeighborhoodSerializer(PFBModelSerializer):

    class Meta:
        model = Neighborhood
        fields = '__all__'
        read_only_fields = ('uuid', 'created', 'created_by', 'modified_by', 'organization')
