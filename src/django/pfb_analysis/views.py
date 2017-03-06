from rest_framework.filters import DjangoFilterBackend, OrderingFilter
from rest_framework.viewsets import ModelViewSet

from pfb_analysis.models import AnalysisJob
from pfb_analysis.serializers import AnalysisJobSerializer
from pfb_network_connectivity.filters import OrgAutoFilterBackend, SelfUserAutoFilterBackend
from pfb_network_connectivity.permissions import RestrictedCreate


class AnalysisJobViewSet(ModelViewSet):
    """
    For listing or retrieving analysis jobs.
    """
    queryset = AnalysisJob.objects.all()
    serializer_class = AnalysisJobSerializer
    permission_classes = (RestrictedCreate,)
    filter_fields = ('status', 'neighborhood',)
    filter_backends = (DjangoFilterBackend, OrderingFilter,
                       OrgAutoFilterBackend, SelfUserAutoFilterBackend)
    ordering_fields = ('created',)

    def perform_create(self, serializer):
        instance = serializer.save()
        instance.run()
