"""Filters for automatically restricting access to resources

These filters are used to limit access based on membership to organizations
or role within an organization
"""
from rest_framework import filters, exceptions

from pfb_network_connectivity.permissions import is_admin_org, is_admin
from users.models import Organization


class OrgAutoFilterBackend(filters.BaseFilterBackend):
    """Filter that only allows users to see their organization's own objects."""

    def filter_queryset(self, request, queryset, view):
        if queryset.model == Organization:
            return queryset.filter(uuid=request.user.organization_id)
        else:
            return queryset.filter(organization=request.user.organization)


class OrgOrAdminAutoFilterBackend(filters.BaseFilterBackend):
    """Filter that allows non-admin users to see only their own organization's objects."""

    def filter_queryset(self, request, queryset, view):
        if is_admin_org(request.user):
            return queryset
        elif queryset.model == Organization:
            return queryset.filter(uuid=request.user.organization_id)
        else:
            return queryset.filter(organization=request.user.organization)


class SelfUserAutoFilterBackend(filters.BaseFilterBackend):
    """Filter used on users endpoint to limit queryset to only user if user is not admin"""

    def filter_queryset(self, request, queryset, view):
        if is_admin(request.user):
            return queryset
        else:
            return queryset.filter(uuid=request.user.uuid)
