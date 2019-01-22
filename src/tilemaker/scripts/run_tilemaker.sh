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
    TL_STYLE_NAME="${2:-$TL_SHAPEFILE_NAME}"

    update_status "TILING" "Style ${TL_STYLE_NAME}" "Using shapefile ${TL_SHAPEFILE_NAME}"

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
    export TL_BOUNDS=$(ogrinfo -so -al "/data/${TL_SHAPEFILE_NAME}.shp" \
        | grep Extent | sed -E 's/.*\((.*), (.*)\) - \((.*), (.*)\).*/\1 \2 \3 \4/')

    # Make tiles and upload them to S3.
    # 'tl' only has totally-quiet or very-verbose (every tile) output options, so we filter
    # the output to show the first line then every 1000th line thereafter.
    #
    # The work is done in the two functions, which are spawned in many (relatively) bit-sized
    # pieces with `parallel`

    # Define these once to save space below. They need to be exported because they'll be used
    # in the functions.
    export TL_INPUT="mapnik:///opt/pfb/tilemaker/styles/${TL_STYLE_NAME}_style.xml"
    export TL_OUTPUT="s3://${AWS_STORAGE_BUCKET_NAME}/${PFB_S3_TILES_PATH}/${TL_STYLE_NAME}/{z}/{x}/{y}.png"
    # To generate locally instead of straight-to-S3, the destination param would be something like:
    # export TL_OUTPUT="file:///data/tiles/${TL_STYLE_NAME}/"

    # Function to generate tiles for the given zoomlevel for the whole area.
    # For low-zoom layers that run fast anyway, partitioning isn't much of a win because the
    # tiles on the edges that get generated twice will account for a significant percentage
    # of the total.
    function run_tl_zoom() {
        ZOOMLEVEL="${1}"
        /usr/bin/time tl copy --min-zoom "${ZOOMLEVEL}" --max-zoom "${ZOOMLEVEL}" \
            --bounds "${TL_BOUNDS}" \
            "${TL_INPUT}" "${TL_OUTPUT}" \
            | awk 'NR == 1 || NR % 1000 == 0'
    }

    # Function to generate tiles for the given zoomlevel and the given partition, where the
    # partition is made by splitting the space into NUM_PARTS longitude bands and setting
    # the bounding box to only the one indicated by PART.
    function run_partitioned_tl() {
        NUM_PARTS="${1}"
        PART="${2}"
        ZOOMLEVEL="${3}"
        TL_SUB_BOUNDS=$(/opt/pfb/tilemaker/scripts/split_bbox.py "${TL_BOUNDS} ${NUM_PARTS} ${PART}")

        /usr/bin/time tl copy --min-zoom "${ZOOMLEVEL}" --max-zoom "${ZOOMLEVEL}" \
            --bounds "${TL_SUB_BOUNDS}" \
            "${TL_INPUT}" "${TL_OUTPUT}" \
            | awk 'NR == 1 || NR % 1000 == 0'
    }

    export -f run_tl_zoom
    export -f run_partitioned_tl

    echo "Launching low-zoom ${TL_SHAPEFILE_NAME}:${TL_STYLE_NAME} tile generation commands"
    parallel --no-notice run_tl_zoom ::: `seq ${TL_MIN_ZOOM} 12`

    echo "Launching partitioned ${TL_SHAPEFILE_NAME}:${TL_STYLE_NAME} tile generation commands"
    parallel --no-notice run_partitioned_tl "${TL_NUM_PARTS}" {2} {1} \
        ::: `seq 13 ${TL_MAX_ZOOM}` \
        ::: `seq 1 ${TL_NUM_PARTS}`

    popd
}

if [ -n "${TL_SHAPEFILE_NAME}" ]; then
    generate_tiles_from_shapefile "${TL_SHAPEFILE_NAME}"
else
    generate_tiles_from_shapefile "neighborhood_ways"
    generate_tiles_from_shapefile "neighborhood_census_blocks"
    generate_tiles_from_shapefile "neighborhood_ways" \
        "neighborhood_bike_infrastructure"
fi
