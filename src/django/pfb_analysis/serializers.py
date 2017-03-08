from pfb_analysis.models import AnalysisJob, Neighborhood
from pfb_network_connectivity.serializers import PFBModelSerializer


class AnalysisJobSerializer(PFBModelSerializer):

    class Meta:
        model = AnalysisJob
        exclude = ('created_at', 'modified_at', 'created_by', 'modified_by')
        read_only_fields = ('uuid', 'createdAt', 'modifiedAt', 'createdBy', 'modifiedBy',
                            'batch_job_id', 'status')


class NeighborhoodSerializer(PFBModelSerializer):

    class Meta:
        model = Neighborhood
        exclude = ('created_at', 'modified_at', 'created_by', 'modified_by')
        read_only_fields = ('uuid', 'createdAt', 'modifiedAt', 'createdBy', 'modifiedBy',
                            'organization', 'name')
