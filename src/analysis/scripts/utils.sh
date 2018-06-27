#!/bin/bash

function update_status() {
    # Usage:
    #    update_status STATUS [step [message]]
    if [ -n "${PFB_JOB_ID}" ];
    then
        echo "Updating job status: $@"
        /opt/pfb/django/manage.py update_status "${PFB_JOB_ID}" "$@"
    fi
}

function update_overall_scores() {
    # Usage:
    #    update_overall_scores OVERALL_SCORES_CSV
    if [ -n "${PFB_JOB_ID}" ];
    then
        /opt/pfb/django/manage.py load_overall_scores --skip-columns \
                                                        human_explanation \
                                                        "${PFB_JOB_ID}" "$@"
    fi
}

function set_job_attr() {
    # Usage:
    #    update_job_attr ATTRIBUTE VALUE
    if [ -n "${PFB_JOB_ID}" ];
    then
        /opt/pfb/django/manage.py set_job_attr "${PFB_JOB_ID}" "$@"
    fi
}
