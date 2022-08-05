#!/bin/bash

set -e

cd `dirname "${0}"`

if [[ -n "${PFB_DEBUG}" ]]; then
    set -x
fi

function usage() {
    echo -n \
"
Usage: $(basename "$0") <path to boundary file> <state abbrev of boundary> <state fips of boundary>

Import all necessary files to run the analysis. See the scripts this calls for specific
ENV configuration options.

"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]
then
    if [ "${1:-}" = "--help" ] || [ -z "${1:-}" ]
    then
        usage
    else
        PFB_SHPFILE="${1}"
        PFB_OSM_FILE="${2}"
        PFB_COUNTRY="${3}"
        PFB_STATE="${4}"
        PFB_STATE_FIPS="${5}"

        ../import/import_neighborhood.sh $PFB_SHPFILE $PFB_COUNTRY $PFB_STATE $PFB_STATE_FIPS
        if [ "$RUN_IMPORT_JOBS" == "1" ]; then
            ../import/import_jobs.sh $PFB_COUNTRY $PFB_STATE
        else
            echo "Skipping Importing Jobs"
        fi
        ../import/import_osm.sh $PFB_OSM_FILE
    fi
fi
