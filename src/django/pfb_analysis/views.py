from rest_framework.viewsets import ViewSet

from pfb_analysis.models import AnalysisJob
from pfb_analysis.serializers import AnalysisJobSerializer


class AnalysisJobViewSet(ViewSet):
    """
    For listing or retrieving analysis jobs.
    """
    def list(self, request):
        queryset = AnalysisJob.objects.all()
        serializer = AnalysisJobSerializer(queryset, many=True)
        return Response(serializer.data)

    def retrieve(self, request, pk=None):
        queryset = AnalysisJob.objects.all()
        job = get_object_or_404(queryset, pk=pk)
        serializer = AnalysisJobSerializer(user)
        return Response(serializer.data)
