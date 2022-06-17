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
from django.conf.urls import include
from django.urls import re_path
from django.contrib import admin
from django.contrib.staticfiles.urls import staticfiles_urlpatterns

from rest_framework import routers

from users import views as user_views
from pfb_analysis import views as analysis_views

router = routers.DefaultRouter()

router.register(r'organizations', user_views.OrganizationViewSet, basename='organizations')
router.register(r'users', user_views.PFBUserViewSet, basename='users')
router.register(r'analysis_batches', analysis_views.AnalysisBatchViewSet,
                basename='analysis_batches')
router.register(r'analysis_jobs', analysis_views.AnalysisJobViewSet, basename='analysis_jobs')
router.register(r'local_upload_tasks', analysis_views.AnalysisLocalUploadTaskViewSet,
                basename='local_upload_tasks')
router.register(r'score_metadata', analysis_views.AnalysisScoreMetadataViewSet,
                basename='score_metadata')
router.register(r'neighborhoods', analysis_views.NeighborhoodViewSet, basename='neighborhoods')


urlpatterns = [
    re_path(r'^admin/', admin.site.urls),
    re_path(r'^api/', include((router.urls, 'api'))),
    re_path(r'^api-auth/', include('rest_framework.urls')),

    # Countries view
    re_path(r'^api/countries/', analysis_views.CountriesView.as_view()),

    # Neighborhood points set
    re_path(r'^api/neighborhoods_geojson/', analysis_views.NeighborhoodGeoJsonViewSet.as_view()),

    # Neighborhood bounds
    re_path(r'^api/neighborhoods_bounds_geojson/$',
        analysis_views.NeighborhoodBoundsGeoJsonViewList.as_view()),
    re_path(r'^api/neighborhoods_bounds_geojson/(?P<neighborhood>[0-9a-f-]+)/$',
        analysis_views.NeighborhoodBoundsGeoJsonViewDetail.as_view()),


    # User Views
    re_path(r'^api/login/', user_views.PFBUserLoginView.as_view()),
    re_path(r'^api/logout/', user_views.PFBUserLogoutView.as_view()),
    re_path(r'^api/users/(?P<pk>.+)/set-password',
        user_views.PFBUserViewSet.as_view({'post': 'set_password'})),

    # Password Reset
    re_path(r'^api/request-password-reset/', user_views.PFBRequestPasswordReset.as_view()),
    re_path(r'^api/reset-password/', user_views.PFBResetPassword.as_view()),

    # 3rd party
    re_path(r'^healthcheck/', include('watchman.urls'))
]

if settings.DEBUG:
    urlpatterns += staticfiles_urlpatterns()
