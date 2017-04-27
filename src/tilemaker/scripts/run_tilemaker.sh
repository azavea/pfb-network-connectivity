#!/bin/bash

# Downloads a shapefile and converts it to raster tiles that it writes to S3
# Requires the following vars to be defined in the environment:
# - AWS_STORAGE_BUCKET_NAME
# - PFB_S3_RESULTS_PATH
# - PFB_S3_TILES_PATH
# - TL_MIN_ZOOM
# - TL_MAX_ZOOM

set -e
source /opt/pfb/tilemaker/scripts/utils.sh

function generate_tiles_from_shapefile() {
    TL_SHAPEFILE_NAME="$1"

    update_status "TILING" "Generating tiles for ${TL_SHAPEFILE_NAME}"

    PFB_TEMPDIR="${NB_TEMPDIR:-$(mktemp -d)}/tilemaker"
    mkdir -p "${PFB_TEMPDIR}"

    pushd $PFB_TEMPDIR

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

    # Make tiles and upload them to S3.
    # 'tl' only has totally-quiet or very-verbose (every tile) output options, so this filters
    # the output to show the first line then every 1000th line thereafter.
    /usr/bin/time -f "\nTIMING: %C\nTIMING:\t%E elapsed %Kkb mem\n" \
    tl copy --min-zoom "${TL_MIN_ZOOM}" --max-zoom "${TL_MAX_ZOOM}" \
        --bounds "${TL_BOUNDS}" \
        "mapnik:///opt/pfb/tilemaker/styles/${TL_SHAPEFILE_NAME}_style.xml" \
        "s3://${AWS_STORAGE_BUCKET_NAME}/${PFB_S3_TILES_PATH}/${TL_SHAPEFILE_NAME}/{z}/{x}/{y}.png" \
        | awk 'NR == 1 || NR % 1000 == 0'

    popd
}

generate_tiles_from_shapefile "neighborhood_ways"
generate_tiles_from_shapefile "neighborhood_census_blocks"
