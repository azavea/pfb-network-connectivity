#!/bin/bash

# Downloads a shapefile and converts it to raster tiles that it writes to S3

set -e

# Get the job ID either as an arg or from the environment
PFB_JOB_ID="${1:-$PFB_JOB_ID}"

if [ -z "${PFB_JOB_ID}" ]; then
    echo "Error: PFB_JOB_ID is required"
    exit 1
fi

TL_SHAPEFILE_NAME="${TL_SHAPEFILE_NAME:-neighborhood_ways}"
TL_MIN_ZOOM="${TL_MIN_ZOOM:-8}"
TL_MAX_ZOOM="${TL_MAX_ZOOM:-17}"

PFB_TEMPDIR=`mktemp -d`

TL_AWS_RESULTS_PATH="s3://${AWS_STORAGE_BUCKET_NAME}/results/${PFB_JOB_ID}"

# Download and unzip shapefile
pushd $PFB_TEMPDIR
aws s3 cp "${TL_AWS_RESULTS_PATH}/${TL_SHAPEFILE_NAME}.zip" ./
unzip "${TL_SHAPEFILE_NAME}.zip"
popd

mkdir -p /data
ogr2ogr -t_srs EPSG:4326 -f GeoJSON "/data/${TL_SHAPEFILE_NAME}.json" \
    "${PFB_TEMPDIR}/${TL_SHAPEFILE_NAME}.shp"

# Get bounds
TL_BOUNDS=$(geojson-extent < "/data/${TL_SHAPEFILE_NAME}.json" spaces)

# Make tiles and upload them to S3
tl copy -z "${TL_MIN_ZOOM}" -Z "${TL_MAX_ZOOM}" -b "${TL_BOUNDS}" \
    "mapnik:///opt/tl-export/styles/${TL_SHAPEFILE_NAME}_style.xml" \
    "${TL_AWS_RESULTS_PATH}/tiles/{z}/{x}/{y}.png?acl=public-read"

# Drop to a shell if run interactively
bash
