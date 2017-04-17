#!/bin/bash

# Downloads a shapefile and converts it to raster tiles that it writes to S3

set -e

export TL_SHAPEFILE_NAME="${TL_SHAPEFILE_NAME:-neighborhood_ways}"
export TL_MIN_ZOOM="${TL_MIN_ZOOM:-8}"
export TL_MAX_ZOOM="${TL_MAX_ZOOM:-17}"

if [ -z "${PFB_JOB_ID}" ]; then
    echo "Error: PFB_JOB_ID is required"
    exit 1
fi

function update_status() {
    /opt/pfb/django/manage.py update_status "${PFB_JOB_ID}" "$@"
}

update_status "TILING" "Exporting tiles"

set +e
/opt/pfb/tilemaker/scripts/run_tilemaker.sh
PFB_EXIT_STATUS=$?
set -e

if [ $PFB_EXIT_STATUS -eq  0 ]; then
    update_status "COMPLETE" "Finished exporting tiles"
else
    update_status "ERROR" "Failed" "See job logs for more details."
fi

# Drop to a shell if run interactively
bash

exit $PFB_EXIT_STATUS
