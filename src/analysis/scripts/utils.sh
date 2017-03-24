#!/bin/bash

function update_status() {
    # Usage:
    #    update_status STATUS [step [message]]

    /opt/pfb/django/manage.py update_status "${PFB_JOB_ID}" "$@"
}

function update_overall_scores() {
    # Usage:
    #    update_overall_scores OVERALL_SCORES_CSV

    /opt/pfb/django/manage.py load_overall_scores "${PFB_JOB_ID}" "$@"
}
