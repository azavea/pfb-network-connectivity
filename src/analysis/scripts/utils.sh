#!/bin/bash

function update_status() {
    # Usage:
    #    update_status STATUS [step [message]]

    /opt/pfb/django/manage.py update_status "${PFB_JOB_ID}" "$@"
}
