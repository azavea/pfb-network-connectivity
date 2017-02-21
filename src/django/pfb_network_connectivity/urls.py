"""pfb_network_connectivity URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.10/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.conf.urls import url, include
    2. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
from django.conf import settings
from django.conf.urls import include, url
from django.contrib import admin
from django.contrib.staticfiles.urls import staticfiles_urlpatterns

from rest_framework import routers

from users import views as user_views

router = routers.DefaultRouter()

router.register(r'users', user_views.PFBUserViewSet, base_name='users')


urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^api/', include(router.urls, namespace='api')),
    url(r'^api-auth/', include('rest_framework.urls', namespace='rest_framework')),

    # User Views
    url(r'^api/login/', user_views.PFBUserLoginView.as_view()),
    url(r'^api/logout/', user_views.PFBUserLogoutView.as_view()),
    url(r'^api/users/(?P<pk>.+)/set-password',
        user_views.PFBUserViewSet.as_view({'post': 'set_password'})),

    # Password Reset
    url(r'^api/request-password-reset/', user_views.PFBRequestPasswordReset.as_view()),
    url(r'^api/reset-password/', user_views.PFBResetPassword.as_view()),

]

if settings.DEBUG:
    urlpatterns += staticfiles_urlpatterns()
