#!/bin/bash

function import_geometries_for_job() {
    if [ -n "${PFB_JOB_ID}" ];
    then
        /opt/pfb/django/manage.py import_results_shapefiles "${PFB_JOB_ID}"
    fi
}

function update_status() {
    # Usage:
    #    update_status STATUS [step [message]]
    echo "Updating job status: $@"
    if [ -n "${PFB_JOB_ID}" ];
    then
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

function update_default_speeds() {
    # Usage:
    #    update_default_speeds OVERALL_SPEEDS_CSV
    if [ -n "${PFB_JOB_ID}" ];
    then
        /opt/pfb/django/manage.py load_default_speeds "${PFB_JOB_ID}" --state_file "${STATE_SPEED_FILE}" --city_file "${CITY_SPEED_FILE}" --output_path "${OUTPUT_DIR}"
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
