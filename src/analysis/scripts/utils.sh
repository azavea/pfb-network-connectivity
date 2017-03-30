#!/bin/bash

function update_status() {
    # Usage:
    #    update_status STATUS [step [message]]

    /opt/pfb/django/manage.py update_status "${PFB_JOB_ID}" "$@"
}

function update_overall_scores() {
    # Usage:
    #    update_overall_scores OVERALL_SCORES_CSV

    /opt/pfb/django/manage.py load_overall_scores --skip-columns human_explanation "${PFB_JOB_ID}" "$@"
}

function set_job_attr() {
    # Usage:
    #    update_job_attr ATTRIBUTE VALUE

    /opt/pfb/django/manage.py set_job_attr "${PFB_JOB_ID}" "$@"
}
