"""Utility functions for User views/serializers"""

from django.conf import settings
from django.core.signing import TimestampSigner


def get_password_reset_url(request, user):
    """Generates a password reset URL given a Request and user

    Args:
        request (rest_framework.request.Request)
        user (PBBUser): user to generate password reset url for
    """
    signer = TimestampSigner(salt=settings.RESET_SALT)
    token = signer.sign('{}'.format(user.uuid))
    return request.build_absolute_uri('/#/password-reset/?token={}'.format(token))
