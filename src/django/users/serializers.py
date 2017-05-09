"""Serializers for Users, Organizations, and other models in app"""

from rest_framework import (
    exceptions,
    permissions,
    serializers
)

from pfb_network_connectivity.serializers import PFBModelSerializer
from users.models import Organization, OrganizationTypes, PFBUser, UserRoles
from pfb_network_connectivity.permissions import (is_admin,
                                                  is_admin_org,
                                                  is_org_admin)


class OrganizationSerializer(PFBModelSerializer):
    """Serializer for organization model"""

    orgType = serializers.CharField(source='org_type')
    label = serializers.CharField(required=False, allow_blank=True, allow_null=True)

    class Meta:
        model = Organization
        fields = ('uuid', 'name', 'label', 'orgType', 'createdBy', 'modifiedBy',
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
    isAdminOrganization = serializers.SerializerMethodField()
    username = serializers.SerializerMethodField()

    class Meta:
        model = PFBUser
        fields = ('uuid', 'username', 'email', 'isActive', 'firstName',
                  'lastName', 'organization', 'orgName',
                  'token', 'role', 'isAdminOrganization',
                  'createdAt', 'modifiedAt', 'createdBy', 'modifiedBy')

    def get_username(self, obj):
        return obj.email

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
        # if admin, no restrictions
        if is_admin(self.request.user):
            return value
        # org admins can only set role to their access or below, and can't change admin role
        elif is_org_admin(self.request.user):
            if value == UserRoles.ADMIN:
                if hasattr(self.instance, 'role') and value != self.instance.role:
                    raise exceptions.PermissionDenied(detail='Organization administrators cannot put users in administrative role')  # NOQA: E501
                else:
                    raise exceptions.PermissionDenied(detail='Organization administrators cannot modify administrative users.')  # NOQA: E501
            elif (value != UserRoles.ADMIN and self.instance and hasattr(self.instance, 'role') and
                  self.instance.role == UserRoles.ADMIN):
                    raise exceptions.PermissionDenied(detail='Organization administrators cannot change role of administrative user')  # NOQA: E501
            else:
                return value
        if (hasattr(self.instance, 'role') and value != self.instance.role and not
                is_admin(self.request.user)):
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

        # admin or org admin allowed to set to their own organization
        if (is_admin(self.request.user) or is_org_admin(self.request.user)):
            if self.request.user.organization.label == value.label:
                return value

        raise exceptions.PermissionDenied(detail="Unable to set user's organization")
