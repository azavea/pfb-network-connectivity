#!/bin/bash

# Downloads a shapefile and converts it to raster tiles that it writes to S3

set -e

TL_SHAPEFILE_NAME="${TL_SHAPEFILE_NAME:-neighborhood_ways}"
TL_MIN_ZOOM="${TL_MIN_ZOOM:-8}"
TL_MAX_ZOOM="${TL_MAX_ZOOM:-17}"

if [ -z "${PFB_JOB_ID}" ]; then
    echo "Error: PFB_JOB_ID is required"
    exit 1
fi

function update_status() {
    /opt/pfb/django/manage.py update_status "${PFB_JOB_ID}" "$@"
}

update_status "TILING" "Exporting tiles"

PFB_TEMPDIR=`mktemp -d`
cd $PFB_TEMPDIR

# Download and unzip shapefile
aws s3 cp "s3://${AWS_STORAGE_BUCKET_NAME}/${PFB_S3_RESULTS_PATH}/${TL_SHAPEFILE_NAME}.zip" ./
unzip "${TL_SHAPEFILE_NAME}.zip"

mkdir -p /data
# Reproject. Could convert to GeoJSON as well, but shapefile is smaller and the tile conversion
# can handle it just as well.
ogr2ogr -overwrite -t_srs EPSG:4326 -f "ESRI Shapefile" "/data/" \
    "${PFB_TEMPDIR}/${TL_SHAPEFILE_NAME}.shp"

# Get bounds. ogrinfo can handle big files, but doesn't provide tons of output flexibility, so
# parse out the answer from the blob of text it returns.
TL_BOUNDS=$(ogrinfo -so -al "/data/${TL_SHAPEFILE_NAME}.shp" \
    | grep Extent | sed -E 's/.*\((.*), (.*)\) - \((.*), (.*)\).*/\1 \2 \3 \4/')

# Make tiles and upload them to S3
/usr/bin/time -f "\nTIMING: %C\nTIMING:\t%E elapsed %Kkb mem\n" \
tl copy -z "${TL_MIN_ZOOM}" -Z "${TL_MAX_ZOOM}" -b "${TL_BOUNDS}" \
    "mapnik:///opt/pfb/tilemaker/styles/${TL_SHAPEFILE_NAME}_style.xml" \
    "s3://${AWS_STORAGE_BUCKET_NAME}/${PFB_S3_TILES_PATH}/{z}/{x}/{y}.png"

update_status "COMPLETE" "Finished exporting tiles"


# Drop to a shell if run interactively
bash
