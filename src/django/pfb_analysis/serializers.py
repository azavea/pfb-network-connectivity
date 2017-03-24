from rest_framework import serializers

from pfb_analysis.models import AnalysisJob, Neighborhood
from pfb_network_connectivity.serializers import PFBModelSerializer


class AnalysisJobSerializer(PFBModelSerializer):

    running_time = serializers.SerializerMethodField()
    start_time = serializers.SerializerMethodField()
    status = serializers.SerializerMethodField()

    def get_running_time(self, obj):
        return obj.running_time

    def get_start_time(self, obj):
        return obj.start_time

    def get_status(self, obj):
        return obj.status

    class Meta:
        model = AnalysisJob
        exclude = ('created_at', 'modified_at', 'created_by', 'modified_by', 'overall_scores',)
        read_only_fields = ('uuid', 'createdAt', 'modifiedAt', 'createdBy', 'modifiedBy',
                            'batch_job_id', 'batch',)


class NeighborhoodSerializer(PFBModelSerializer):

    class Meta:
        model = Neighborhood
        exclude = ('created_at', 'modified_at', 'created_by', 'modified_by')
        read_only_fields = ('uuid', 'createdAt', 'modifiedAt', 'createdBy', 'modifiedBy',
                            'organization', 'name')
