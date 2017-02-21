"""Serializers for Users, Organizations, and other models in app"""

from rest_framework import (
    exceptions,
    permissions,
    serializers
)

from pfb_network_connectivity.models import Neighborhood
from pfb_network_connectivity.serializers import PFBModelSerializer
from users.models import Organization, OrganizationTypes, PFBUser
from pfb_network_connectivity.permissions import is_admin, is_admin_org


class OrganizationSerializer(PFBModelSerializer):
    """Serializer for organization model"""

    orgType = serializers.CharField(source='org_type')
    neighborhood = serializers.SlugRelatedField(slug_field='abbreviation', required=False,
                                                allow_null=True,
                                                queryset=Neighborhood.objects.all())
    label = serializers.CharField(required=False, allow_blank=True, allow_null=True)

    class Meta:
        model = Organization
        fields = ('uuid', 'name', 'label', 'orgType', 'neighborhood', 'createdBy', 'modifiedBy',
                  'createdAt', 'modifiedAt')


class PFBUserSerializer(PFBModelSerializer):
    """Serializer for PFB User

    Note:
        Retrieves token if available for a user, or returns ``null``
    """

    token = serializers.SerializerMethodField()
    isActive = serializers.BooleanField(source='is_active', default=True)
    firstName = serializers.CharField(source='first_name', allow_blank=True, required=False)
    lastName = serializers.CharField(source='last_name', allow_blank=True, required=False)
    organization = serializers.SlugRelatedField(queryset=Organization.objects.all(),
                                                slug_field='label')
    orgName = serializers.SerializerMethodField()
    neighborhood = serializers.SerializerMethodField()
    isAdminOrganization = serializers.SerializerMethodField()
    username = serializers.SerializerMethodField()

    class Meta:
        model = PFBUser
        fields = ('uuid', 'username', 'email', 'isActive', 'firstName',
                  'lastName', 'organization', 'orgName', 'neighborhood',
                  'token', 'role', 'isAdminOrganization',
                  'createdAt', 'modifiedAt', 'createdBy', 'modifiedBy')

    def get_username(self, obj):
        return obj.email

    def get_neighborhood(self, obj):
        if obj.organization and obj.organization.neighborhood:
            return obj.organization.neighborhood.abbreviation
        else:
            return None

    def get_orgName(self, obj):
        if obj.organization:
            return obj.organization.name
        else:
            return None

    def get_token(self, obj):
        if obj.token:
            return obj.token.key
        else:
            return None

    def get_isAdminOrganization(self, obj):
        return obj.organization.org_type == OrganizationTypes.ADMIN

    def validate_role(self, value):
        # if post and admin, no restrictions
        if self.request.method == 'POST' and is_admin(self.request.user):
            return value

        if value != self.instance.role and not is_admin(self.request.user):
            raise exceptions.PermissionDenied(detail="Cannot change a user's group")
        else:
            return value

    def validate_organization(self, value):
        is_post = self.request.method == 'POST'
        request_user = self.request.user

        # safe method, nothing to worry about
        if self.request.method in permissions.SAFE_METHODS:
            return value

        # no change in organization and not a create, nothing to worry about
        if not is_post and self.instance.organization.label == value.label:
            return value

        # if user is in admin org and is an admin, no restrictions
        if is_admin_org(self.request.user) and is_admin(self.request.user):
            return value

        # admin is setting org to same, acceptable
        if is_admin(self.request.user) and request_user.organization.label == value.label:
            return value
        else:
            raise exceptions.PermissionDenied(detail="Unable to set user's organization")
