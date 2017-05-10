from collections import OrderedDict

from rest_framework import serializers

from pfb_analysis.models import AnalysisJob, Neighborhood
from pfb_network_connectivity.serializers import PFBModelSerializer


class PrimaryKeyReferenceRelatedField(serializers.PrimaryKeyRelatedField):
    """A custom relational field for read-only objects.

    This field is for the specific case where:
    1. We want to reference the model on create by its primary key
    2. We want to print the full serialized representation of the object on to_representation,
       using a serializer of our choice
    """

    def __init__(self, **kwargs):
        """Custom init to take an extra 'serializer' argument

        @param serializer A custom serializer instance, used to generate the object representation
                          in to_representation()
        """
        self.serializer = kwargs.pop('serializer')
        super(PrimaryKeyReferenceRelatedField, self).__init__(**kwargs)

    def use_pk_only_optimization(self):
        return False

    def to_representation(self, value):
        if self.allow_null is True and value.pk is None:
            return None
        try:
            serializer = self.serializer(value)
            return serializer.data
        except self.serializer.Meta.model.DoesNotExist:
            self.fail('does_not_exist', pk_value=value.pk)
        except (TypeError, ValueError):
            self.fail('incorrect_type', data_type=type(value).__name__)

    def get_choices(self, cutoff=None):
        """This is used to get the param value for the POST form in the DRF browsable API.
        It normally uses `to_representation` to get the param value, but we want it to use `pk`.
        """
        queryset = self.get_queryset()
        if queryset is None:
            # Ensure that field.choices returns something sensible
            # even when accessed with a read-only field.
            return {}

        if cutoff is not None:
            queryset = queryset[:cutoff]

        return OrderedDict([(item.pk, self.display_value(item)) for item in queryset])


class NeighborhoodSerializer(PFBModelSerializer):

    class Meta:
        model = Neighborhood
        exclude = ('created_at', 'modified_at', 'created_by', 'modified_by', 'geom', 'geom_simple',
                   'geom_pt',)
        read_only_fields = ('uuid', 'createdAt', 'modifiedAt', 'createdBy', 'modifiedBy',
                            'organization', 'name',)


class NeighborhoodSummarySerializer(PFBModelSerializer):
    """Serializer for including neighborhood information in AnalysisJob results.

    All the fields are read-only. Any changes to neighborhoods should happen through the
    neighborhoods endpoint, which uses the regular serializer.
    """

    class Meta:
        model = Neighborhood
        fields = ('uuid', 'name', 'label', 'state_abbrev', 'organization', 'geom_pt')
        read_only_fields = fields


class AnalysisJobSerializer(PFBModelSerializer):

    logs_url = serializers.SerializerMethodField()
    running_time = serializers.SerializerMethodField()
    start_time = serializers.SerializerMethodField()
    status = serializers.SerializerMethodField()
    neighborhood = PrimaryKeyReferenceRelatedField(queryset=Neighborhood.objects.all(),
                                                   serializer=NeighborhoodSummarySerializer)
    overall_score = serializers.FloatField(read_only=True)

    def get_logs_url(self, obj):
        return obj.logs_url

    def get_running_time(self, obj):
        return obj.running_time

    def get_start_time(self, obj):
        return obj.start_time

    def get_status(self, obj):
        return obj.status

    class Meta:
        model = AnalysisJob
        exclude = ('created_at', 'modified_at', 'created_by', 'modified_by', 'overall_scores',
                   'analysis_job_definition', 'tilemaker_job_definition',
                   '_analysis_job_name', '_tilemaker_job_name',)
        read_only_fields = ('uuid', 'createdAt', 'modifiedAt', 'createdBy', 'modifiedBy',
                            'batch_job_id', 'batch', 'census_block_count', 'final_runtime',)
