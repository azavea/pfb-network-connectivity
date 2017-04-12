
from django.utils.timezone import now

from rest_framework import serializers
from rest_framework.serializers import CreateOnlyDefault
from rest_framework.fields import CurrentUserDefault
from pfb_network_connectivity.models import PFBModel


class PFBModelSerializer(serializers.ModelSerializer):
    """Base serializer for PFBModel

    This base serializer should be used for any serializer that needs
    to serialize a model that inherites from ``PFBModel``. It automatically
    handles setting ``created_by`` and ``modified_by``
    """

    def __init__(self, *args, **kwargs):
        super(PFBModelSerializer, self).__init__(*args, **kwargs)
        self.request = self.context.get('request')

    uuid = serializers.UUIDField(read_only=True)
    createdAt = serializers.DateTimeField(default=CreateOnlyDefault(now), read_only=True,
                                          source='created_at')
    modifiedAt = serializers.DateTimeField(default=now, read_only=True,
                                           source='modified_at')

    createdBy = serializers.HiddenField(default=CreateOnlyDefault(CurrentUserDefault()),
                                        source='created_by')
    modifiedBy = serializers.HiddenField(default=CurrentUserDefault(), source='modified_by')

    class Meta:
        model = PFBModel
