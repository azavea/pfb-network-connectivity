#!/bin/bash

function update_status() {
    # Usage:
    #    update_status STATUS [step [message]]

    echo "Updating job status: $@"
    /opt/pfb/django/manage.py update_status "${PFB_JOB_ID}" "$@"
}
