"""Filters for automatically restricting access to resources

These filters are used to limit access based on membership to organizations
or role within an organization
"""
import logging

from rest_framework import filters

from pfb_network_connectivity.permissions import is_admin_org, is_admin
from pfb_analysis.models import AnalysisJob
from users.models import Organization, PFBUser, UserRoles


logger = logging.getLogger(__name__)


class OrgAutoFilterBackend(filters.BaseFilterBackend):
    """Filter that only allows users to see their organization's own objects."""

    def filter_queryset(self, request, queryset, view):
        if not hasattr(request.user, 'organization'):
            return queryset
        if queryset.model == Organization:
            return queryset.filter(uuid=request.user.organization_id)
        elif queryset.model == AnalysisJob:
            return queryset.filter(neighborhood__organization=request.user.organization)
        else:
            return queryset.filter(organization=request.user.organization)


class OrgOrAdminAutoFilterBackend(filters.BaseFilterBackend):
    """Filter that allows non-admin users to see only their own organization's objects.

    Non suer-admin users cannot see admin users.
    """

    def filter_queryset(self, request, queryset, view):
        if not hasattr(request.user, 'organization') or is_admin(request.user):
            return queryset
        elif queryset.model == Organization:
            return queryset.filter(uuid=request.user.organization_id)
        elif queryset.model == PFBUser:
            queryset = queryset.filter(organization=request.user.organization)
            return queryset.exclude(role=UserRoles.ADMIN)
        else:
            return queryset.filter(organization=request.user.organization)


class SelfUserAutoFilterBackend(filters.BaseFilterBackend):
    """Filter used on users endpoint to limit queryset to only user if user is not admin.

    Org admins cannot see full admins.
    """

    def filter_queryset(self, request, queryset, view):
        if not hasattr(request.user, 'organization') or is_admin(request.user):
            return queryset
        elif is_admin_org(request.user):
            return queryset.exclude(role=UserRoles.ADMIN)
        else:
            return queryset.filter(uuid=request.user.uuid)
