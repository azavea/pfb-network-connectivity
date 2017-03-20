#!/bin/bash

NB_INPUT_SRID="${NB_INPUT_SRID:-4326}"
NB_OUTPUT_SRID="${NB_OUTPUT_SRID:-2163}"
NB_MAX_TRIP_DISTANCE="${NB_MAX_TRIP_DISTANCE:-3300}"
NB_POSTGRESQL_HOST="${NB_POSTGRESQL_HOST:-127.0.0.1}"
NB_POSTGRESQL_DB="${NB_POSTGRESQL_DB:-pfb}"
NB_POSTGRESQL_USER="${NB_POSTGRESQL_USER:-gis}"
NB_POSTGRESQL_PASSWORD="${NB_POSTGRESQL_PASSWORD:-gis}"

NB_TEMPDIR=`mktemp -d`

set -e

if [[ -n "${PFB_DEBUG}" ]]; then
    set -x
fi

function usage() {
    echo -n \
"
Usage: $(basename "$0") <neighborhood_boundary_shapefile> <neighborhood_tiger_state_id>

Import neighborhood boundary to postgres database, overwriting any existing boundary

Requires passing path (relative or absolute) to the neighborhood boundary shapefile.
Requires passing the state FIPS ID that the neighborhood boundary is found in. e.g. MA is 25
    See: https://www.census.gov/geo/reference/ansi_statetables.html

Optional ENV vars:

NB_INPUT_SRID - Default: 4326
NB_OUTPUT_SRID - Default: 2163
NB_MAX_TRIP_DISTANCE - Default: 3300 (in the units of NB_OUTPUT_SRID)
NB_BOUNDARY_BUFFER - Default: half of NB_MAX_TRIP_DISTANCE (in the units of NB_OUTPUT_SRID)
NB_POSTGRESQL_HOST - Default: 127.0.0.1
NB_POSTGRESQL_DB - Default: pfb
NB_POSTGRESQL_USER - Default: gis
NB_POSTGRESQL_PASSWORD - Default: gis

"
}

# Function to import a shapefile (using 'dump' mode for quickness) and convert it to the target SRID
function import_and_transform_shapefile() {
    IMPORT_FILE="${1}"
    IMPORT_TABLENAME="${2}"
    IMPORT_SRID="${3:-4326}"

    echo "START: Importing ${IMPORT_TABLENAME}"
    shp2pgsql -I -d -D -s "${IMPORT_SRID}" "${IMPORT_FILE}" "${IMPORT_TABLENAME}" \
        | psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" > /dev/null
    psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
        -c "ALTER TABLE ${IMPORT_TABLENAME} ALTER COLUMN geom \
            TYPE geometry(MultiPolygon,${NB_OUTPUT_SRID}) USING ST_Force2d(ST_Transform(geom,${NB_OUTPUT_SRID}));"
    echo "DONE: Importing ${IMPORT_TABLENAME}"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]
then
    if [ "${1:-}" = "--help" ] || [ -z "${1:-}" ]
    then
        usage
    else
        NB_BOUNDARY_FILE="${1}"
        NB_STATE_FIPS="${2}"

        let HALF_MAX_TRIP="${NB_MAX_TRIP_DISTANCE}"/2
        NB_BOUNDARY_BUFFER="${NB_BOUNDARY_BUFFER:-$HALF_MAX_TRIP}"

        # Import neighborhood boundary
        import_and_transform_shapefile "${NB_BOUNDARY_FILE}" neighborhood_boundary "${NB_INPUT_SRID}"

        # Get blocks for the state requested
        NB_BLOCK_FILENAME="tabblock2010_${NB_STATE_FIPS}_pophu"
        if [ -f "/data/${NB_BLOCK_FILENAME}.zip" ]; then
            echo "Using local census blocks file"
            BLOCK_DOWNLOAD="/data/${NB_BLOCK_FILENAME}.zip"
        elif [ "${AWS_STORAGE_BUCKET_NAME}" ] && aws s3 ls "s3://${AWS_STORAGE_BUCKET_NAME}/data/${NB_BLOCK_FILENAME}.zip"; then
            echo "Using census blocks file from S3"
            BLOCK_DOWNLOAD="${NB_TEMPDIR}/${NB_BLOCK_FILENAME}.zip"
            aws s3 cp "s3://${AWS_STORAGE_BUCKET_NAME}/data/${NB_BLOCK_FILENAME}.zip" "${BLOCK_DOWNLOAD}"
        else
            BLOCK_DOWNLOAD="${NB_TEMPDIR}/${NB_BLOCK_FILENAME}.zip"
            wget -nv -O "${BLOCK_DOWNLOAD}" "http://www2.census.gov/geo/tiger/TIGER2010BLKPOPHU/${NB_BLOCK_FILENAME}.zip"
        fi
        unzip "${BLOCK_DOWNLOAD}" -d "${NB_TEMPDIR}"

        # Import block shapefile
        import_and_transform_shapefile "${NB_TEMPDIR}/${NB_BLOCK_FILENAME}.shp" neighborhood_census_blocks 4326

        # Only keep blocks in boundary+buffer
        echo "START: Removing blocks outside buffer with size ${NB_BOUNDARY_BUFFER}"
        psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
            -c "DELETE FROM neighborhood_census_blocks AS blocks USING neighborhood_boundary \
                AS boundary WHERE NOT ST_DWithin(blocks.geom, boundary.geom, \
                ${NB_BOUNDARY_BUFFER});"
        echo "DONE: Finished removing blocks outside buffer"

        # Remove NB_TEMPDIR
        rm -rf "${NB_TEMPDIR}"
    fi
fi
