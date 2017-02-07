#!/bin/bash

if [[ -n "${PFB_DEBUG}" ]]; then
    set -x
fi

# determine current working directory in a way that works with `source`
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function usage() {
    echo -n \
"
Usage: set_srid.sh <path to boundary file>

Autodetect the UTM zone for the given boundary file and set the SRID in ENV NB_OUTPUT_SRID

"
}

if [ "${1:-}" = "--help" ] || [ -z "${1:-}" ]
then
    usage
else
    SRID=`python ${DIR}/detect_utm_zone.py "${1}"`
    if [ $? -eq 0 ]; then
        echo "Detected SRID ${SRID}"
        export NB_OUTPUT_SRID=$SRID
    else
        echo "Failed to determine UTM Zone SRID"
        unset NB_OUTPUT_SRID
    fi
fi
