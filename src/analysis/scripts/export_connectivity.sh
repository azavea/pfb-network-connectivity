#!/usr/bin/env bash

# ec prefix stands for 'export connectivity'

set -e

cd $(dirname "$0")
source ./utils.sh


NB_POSTGRESQL_HOST="${NB_POSTGRESQL_HOST:-127.0.0.1}"
NB_POSTGRESQL_DB="${NB_POSTGRESQL_DB:-pfb}"
NB_POSTGRESQL_USER="${NB_POSTGRESQL_USER:-gis}"
NB_POSTGRESQL_PASSWORD="${NB_POSTGRESQL_PASSWORD:-gis}"
NB_POSTGRESQL_PORT="${NB_POSTGRESQL_PORT:-5432}"

function ec_usage() {
    echo -n \
"
Usage: $(basename "$0") <local_directory> <job_id>

Export data from a successful run of the PeopleForBikes Network Analysis.
Writes to <local_directory> and, if AWS_STORAGE_BUCKET_NAME is set,
uploads to S3 at {AWS_STORAGE_BUCKET_NAME}/{job_id}.

<local_directory> must be an absolute path (pgsql COPY doesn't support relative paths)

This script exports the following tables:
 - neighborhood_ways as SHP
 - neighborhood_ways as GeoJSON (TODO)
 - neighborhood_connected_census_blocks as SHP (currently disabled)
 - neighborhood_overall_scores as CSV

Optional ENV vars:

AWS_STORAGE_BUCKET_NAME
AWS_PROFILE (necessary for using S3 in local development)

NB_POSTGRESQL_HOST - Default: 127.0.0.1
NB_POSTGRESQL_DB - Default: pfb
NB_POSTGRESQL_USER - Default: gis
NB_POSTGRESQL_PASSWORD - Default: gis
NB_POSTGRESQL_PORT - Default: 5432

"
}

function ec_export_table_shp() {
    OUTPUT_DIR="$1"
    EXPORT_TABLENAME="$2"

    FILENAME="${OUTPUT_DIR}/${EXPORT_TABLENAME}.shp"
    pgsql2shp -h "${NB_POSTGRESQL_HOST}" \
              -u "${NB_POSTGRESQL_USER}" \
              -p "${NB_POSTGRESQL_PORT}" \
              -P "${NB_POSTGRESQL_PASSWORD}" \
              -f "${FILENAME}" \
              "${NB_POSTGRESQL_DB}" \
              "${EXPORT_TABLENAME}"
    pushd "${OUTPUT_DIR}"
    zip "${EXPORT_TABLENAME}.zip" "${EXPORT_TABLENAME}".*
    rm "${EXPORT_TABLENAME}".[^z]*
    popd
}

function ec_export_table_csv() {
    OUTPUT_DIR="$1"
    EXPORT_TABLENAME="$2"

    FILENAME="${OUTPUT_DIR}/${EXPORT_TABLENAME}.csv"
    psql -h "${NB_POSTGRESQL_HOST}" \
         -U "${NB_POSTGRESQL_USER}" \
         -p "${NB_POSTGRESQL_PORT}" \
         -d "${NB_POSTGRESQL_DB}" \
         -c "\COPY ${EXPORT_TABLENAME} TO '${FILENAME}' WITH (FORMAT CSV, HEADER)"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]
then
    if [ "${1}" = "--help" ]
    then
        ec_usage
    elif [ -z "${1}" ] || [ -z "${2}" ]
    then
        ec_usage
        exit 1
    else
        NB_OUTPUT_DIR="${1}"
        JOB_ID="${2}"
        OUTPUT_DIR="${NB_OUTPUT_DIR}/${JOB_ID}"
        echo "Exporting analysis to ${OUTPUT_DIR}"
        update_status "EXPORTING" "Exporting results"
        mkdir -p "${OUTPUT_DIR}"

        # Export neighborhood_ways as SHP
        ec_export_table_shp "${OUTPUT_DIR}" "neighborhood_ways"

        # Export neighborhood ways as GeoJSON
        # TODO: Add ogr2ogr and try again

        # Export neighborhood_connected_census_blocks as SHP
        # NOTE: disabled for now, because large and not that useful
        # ec_export_table_shp "${OUTPUT_DIR}" "neighborhood_connected_census_blocks"

        # Export neighborhood_overall_scores as CSV
        ec_export_table_csv "${OUTPUT_DIR}" "neighborhood_overall_scores"

        if [ -v AWS_STORAGE_BUCKET_NAME ]
        then
          sync  # Probably superfluous, but the s3 command said "file changed while reading" once
          update_status "EXPORTING" "Uploading results"
          aws s3 cp --recursive "${OUTPUT_DIR}" "s3://${AWS_STORAGE_BUCKET_NAME}/results/${JOB_ID}"
        fi
    fi
fi
