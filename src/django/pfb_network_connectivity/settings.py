# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from datetime import timedelta
import os
import logging.config

import requests

from django.core.exceptions import ImproperlyConfigured

from pfb_analysis.aws_batch import get_latest_job_definition


# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.10/howto/deployment/checklist/

AWS_REGION = os.getenv('AWS_DEFAULT_REGION', 'us-east-1')
DJANGO_ENV = os.getenv('DJANGO_ENV', 'development')

SECRET_KEY = os.getenv('PFB_SECRET_KEY', 'SECRET_KEY_R$^3Pc135NUbst4OIt$Kzrd5zqLo$1h4')
if DJANGO_ENV not in ('development', 'testing') and SECRET_KEY.startswith('SECRET_KEY'):
    raise ImproperlyConfigured('Non-development environments require that env.PFB_SECRET_KEY ' +
                               'be set')

DEV_USER = os.getenv('DEV_USER', None)

DEBUG = DJANGO_ENV == 'development'

ALLOWED_HOSTS = os.getenv('PFB_ALLOWED_HOSTS', '').split(',')
if '' in ALLOWED_HOSTS:
    ALLOWED_HOSTS.remove('')

# solution from https://dryan.com/articles/elb-django-allowed-hosts/
EC2_PRIVATE_IP = None
try:
    EC2_PRIVATE_IP = requests.get('http://169.254.169.254/latest/meta-data/local-ipv4',
                                  timeout=0.1).text
except requests.exceptions.RequestException:
    pass
if EC2_PRIVATE_IP:
    ALLOWED_HOSTS.append(EC2_PRIVATE_IP)

# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # 3rd party
    'django_extensions',
    'rest_framework',
    'rest_framework.authtoken',
    'django_filters',
    'storages',
    'watchman',
    'django_q',
    'django_countries',

    # Application
    'pfb_network_connectivity',
    'pfb_analysis',
    'users',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'pfb_network_connectivity.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'pfb_network_connectivity.wsgi.application'


# Database
# https://docs.djangoproject.com/en/1.10/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.postgis',
        'NAME': os.getenv('PFB_DB_DATABASE', 'pfb'),
        'USER': os.getenv('PFB_DB_USER', 'pfb'),
        'PASSWORD': os.getenv('PFB_DB_PASSWORD', 'pfb'),
        'HOST': os.getenv('PFB_DB_HOST', 'database.service.pfb.internal'),
        'PORT': os.getenv('PFB_DB_PORT', 5432)
    }
}

# Password validation
# https://docs.djangoproject.com/en/1.10/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Set custom auth user
AUTH_USER_MODEL = 'users.PFBUser'

# Use a write-through cache for session information
SESSION_ENGINE = 'django.contrib.sessions.backends.cached_db'

# Seconds
SESSION_COOKIE_AGE = 14400  # 4 hours


# Internationalization
# https://docs.djangoproject.com/en/1.10/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.10/howto/static-files/

STATIC_URL = '/static/'
STATIC_ROOT = '/static/'

# Logging
# https://docs.djangoproject.com/en/1.10/topics/logging/

LOGGING_CONFIG = None
DJANGO_LOG_LEVEL = os.getenv('DJANGO_LOG_LEVEL', 'INFO')
logging.config.dictConfig({
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'datefmt': '%Y-%m-%d %H:%M:%S %z',
            'format': ('[%(asctime)s] [%(process)d] [%(levelname)s]'
                       ' %(message)s'),
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': DJANGO_LOG_LEVEL,
        },
        'django_q': {
            'handlers': ['console'],
            'level': DJANGO_LOG_LEVEL,
        },
        'pfb_analysis': {
            'handlers': ['console'],
            'level': DJANGO_LOG_LEVEL,
        }
    }
})


# Django Rest Framework
# http://www.django-rest-framework.org/

# Rest Framework Settings
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    # Token has to come first so a 401 is returned if session expires
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ),
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.LimitOffsetPagination',
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.OrderingFilter'
    ],
    'PAGE_SIZE': 20
}

# Watchman
# http://django-watchman.readthedocs.io/en/latest/
WATCHMAN_ERROR_CODE = 503
WATCHMAN_CHECKS = (
    'watchman.checks.databases',
)


# Django Storages
# https://github.com/jschneier/django-storages

DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'
AWS_STORAGE_BUCKET_NAME = os.getenv('PFB_S3_STORAGE_BUCKET',
                                    '{0}-pfb-storage-{1}'.format(DEV_USER, AWS_REGION))
AWS_DEFAULT_ACL = None  # Override the insecure default behavior to silence the warning about it.
AWS_QUERYSTRING_AUTH = False

# Django Q
# https://django-q.readthedocs.io/en/latest/index.html

Q_CLUSTER = {
    'name': 'pfb-network-connectivity',
    'workers': 1,
    'recycle': 1,
    # Three hours. It certainly shouldn't take that long, but it can be slow for big files and
    # failing is a bad option, so we want a big buffer.
    'timeout': 10800,
    # 'retry' is another timeout--the time between when a broker delivers a task and when it
    # gives up on getting a result and delivers it again. It has to be longer than the 'timeout'
    # value or you'll end up with a 2nd copy of a task added to the queue before the first one
    # has definitely finished or been killed.
    'retry': 10860,
    # The default for 'max_attempts' is 0 which means "keep trying forever". It's not clear if
    # retrying will ever work after a failure, but there's always the possibility of weird
    # transient errors, so it's probably worth trying. Too many retries could cause stranded
    # files to use up disk space, though, so one is enough.
    'max_attempts': 2,
    'orm': 'default',
    'poll': 5,
    'cpu_affinity': 1
}

# Email
DEFAULT_FROM_EMAIL = 'noreply@bna.peopleforbikes.org'
REPOSITORY_HELP_EMAIL = os.getenv('REPOSITORY_HELP_EMAIL', 'help@bna.peopleforbikes.org')

# Root user email (the email address of the main admin user for the root org in the database)
ROOT_USER_EMAIL = 'systems+pfb@azavea.com'

if DJANGO_ENV in ['staging', 'production', 'development', 'test']:
    EMAIL_BACKEND = 'django_amazon_ses.EmailBackend'
else:
    raise ImproperlyConfigured('Unknown DJANGO_ENV')

# Added in 3.2, used to create id fields for models where it's not
# explicitly specified in the model definition.
DEFAULT_AUTO_FIELD = "django.db.models.AutoField"

# Password Reset
RESET_TOKEN_LENGTH = timedelta(hours=24)
RESET_SALT = os.getenv('REPOSITORY_RESET_SALT', 'passwordreset')
USER_EMAIL_SUBJECT = os.getenv('REPOSITORY_RESET_EMAIL_SUBJECT', 'Your PFB Account')
RESET_EMAIL_FROM = os.getenv('REPOSITORY_RESET_EMAIL_FROM', DEFAULT_FROM_EMAIL)


# AWS Batch Analysis Job settings
PFB_AWS_BATCH_ANALYSIS_JOB_QUEUE_NAME = os.getenv('PFB_AWS_BATCH_ANALYSIS_JOB_QUEUE_NAME')
if not PFB_AWS_BATCH_ANALYSIS_JOB_QUEUE_NAME:
    raise ImproperlyConfigured('env.PFB_AWS_BATCH_ANALYSIS_JOB_QUEUE_NAME is required')

# Configure with either:
# 1. PFB_AWS_BATCH_ANALYSIS_JOB_DEFINITION_NAME_REVISION = '<name>:<revision>'
#  -- or --
# 2. PFB_AWS_BATCH_ANALYSIS_JOB_DEFINITION_NAME = '<name>'
#   In this case, revision will be autodetected by querying the AWS API
# Case 1 takes precedence and is the value set for use in the app
PFB_AWS_BATCH_ANALYSIS_JOB_DEFINITION_NAME_REVISION = os.getenv('PFB_AWS_BATCH_ANALYSIS_JOB_DEFINITION_NAME_REVISION')
PFB_AWS_BATCH_ANALYSIS_JOB_DEFINITION_NAME = os.getenv('PFB_AWS_BATCH_ANALYSIS_JOB_DEFINITION_NAME')
if PFB_AWS_BATCH_ANALYSIS_JOB_DEFINITION_NAME_REVISION:
    pass
elif PFB_AWS_BATCH_ANALYSIS_JOB_DEFINITION_NAME:
    revision = get_latest_job_definition(PFB_AWS_BATCH_ANALYSIS_JOB_DEFINITION_NAME)['revision']
    PFB_AWS_BATCH_ANALYSIS_JOB_DEFINITION_NAME_REVISION = '{}:{}'.format(PFB_AWS_BATCH_ANALYSIS_JOB_DEFINITION_NAME,
                                                                         revision)
else:
    raise ImproperlyConfigured('env.PFB_AWS_BATCH_ANALYSIS_JOB_DEFINITION_NAME_REVISION or ' +
                               'env.PFB_AWS_BATCH_ANALYSIS_JOB_DEFINITION_NAME is required.')


# Analysis results settings
# A list of destinations types, created by the analysis, to be made available for download
PFB_ANALYSIS_DESTINATIONS = [
    'colleges',
    'community_centers',
    'doctors',
    'dentists',
    'hospitals',
    'pharmacies',
    'parks',
    'retail',
    'schools',
    'social_services',
    'supermarkets',
    'transit',
    'universities',
]
# Length of time in seconds that S3 pre-signed urls are valid for
PFB_ANALYSIS_PRESIGNED_URL_EXPIRES = 3600

# Root URL for tile server.
TILEGARDEN_ROOT = os.getenv('PFB_TILEGARDEN_ROOT')
if not TILEGARDEN_ROOT:
    raise ImproperlyConfigured('env.PFB_TILEGARDEN_ROOT is required')

# Configuration object for whether to collect state/province by country
# 'subdivision_types' is used to filter the subdivisions returned by 'pycountry' in cases where
# there are ones we don't want.
COUNTRY_CONFIG = {
    'default': {
        'use_subdivisions': False,
    },
    'AU': {
        'use_subdivisions': True,
        'subdivisions_required': True,
    },
    'CA': {
        'use_subdivisions': True,
        'subdivisions_required': True,
    },
    'DK': {
        'use_subdivisions': True,
        'subdivisions_required': False,
        # Regions don't have abbreviations in 'pycountry', so we need to define by hand.
        'subdivisions': [
            {'code': 'CR', 'name': 'Capital Region', 'type': 'Region'},
            {'code': 'CD', 'name': 'Central Denmark', 'type': 'Region'},
            {'code': 'SD', 'name': 'Southern Denmark', 'type': 'Region'},
            {'code': 'ND', 'name': 'North Denmark', 'type': 'Region'},
            {'code': 'RZ', 'name': 'Zealand', 'type': 'Region'},
        ]
    },
    'FR': {
        'use_subdivisions': True,
        'subdivisions_required': False,
        'subdivision_types': ['Metropolitan region'],
    },
    'GB': {
        'use_subdivisions': True,
        'subdivisions_required': False,
        'subdivision_types': ['Country', 'Province'],  # just England, Wales, Scotland, N Ireland
    },
    'NL': {
        'use_subdivisions': True,
        'subdivisions_required': False,
        'subdivision_types': ['Province'],  # exclude 'Country' and 'Special Municipality'
    },
    'NO': {
        'use_subdivisions': True,
        'subdivisions_required': False,
        # Regions are not defined in 'pycountry', so we need to define them by hand.
        'subdivisions': [
            {'code': 'AGD', 'name': 'Agder', 'type': 'Region'},
            {'code': 'INN', 'name': 'Innlandet', 'type': 'Region'},
            {'code': 'MOR', 'name': 'Møre og Romsdal', 'type': 'Region'},
            {'code': 'NOR', 'name': 'Nordland', 'type': 'Region'},
            {'code': 'OSL', 'name': 'Oslo', 'type': 'Region'},
            {'code': 'ROG', 'name': 'Rogaland', 'type': 'Region'},
            {'code': 'TOF', 'name': 'Troms og Finnmark', 'type': 'Region'},
            {'code': 'TRO', 'name': 'Trøndelag', 'type': 'Region'},
            {'code': 'VOT', 'name': 'Vestfold og Telemark', 'type': 'Region'},
            {'code': 'VES', 'name': 'Vestlandet', 'type': 'Region'},
            {'code': 'VIK', 'name': 'Viken', 'type': 'Region'},
        ]
    },
    'US': {
        'use_subdivisions': True,
        'subdivisions_required': True,
    },
}
