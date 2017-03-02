#!/usr/bin/env bash

# ec prefix stands for 'export connectivity'

set -e

cd $(dirname "$0")

NB_POSTGRESQL_HOST="${NB_POSTGRESQL_HOST:-127.0.0.1}"
NB_POSTGRESQL_DB="${NB_POSTGRESQL_DB:-pfb}"
NB_POSTGRESQL_USER="${NB_POSTGRESQL_USER:-gis}"
NB_POSTGRESQL_PASSWORD="${NB_POSTGRESQL_PASSWORD:-gis}"
NB_POSTGRESQL_PORT="${NB_POSTGRESQL_PORT:-5432}"
NB_OUTPUT_FILE_PREFIX="${NB_OUTPUT_FILE_PREFIX:-analysis_}"

NB_OUTPUT_DIR="${1}"

function ec_usage() {
    echo -n \
"
Usage: $(basename "$0") <output_directory>

Export data from a successful run of the PeopleForBike Network Analysis to a directory on disk.

<output_directory> must be an absolute path (pgsql COPY doesn't support relative paths)

This script exports the following tables:
 - neighborhood_ways as SHP
 - neighborhood_ways as GeoJSON (TODO)
 - neighborhood_connected_census_blocks as SHP
 - neighborhood_overall_scores as CSV

Optional ENV vars:

NB_OUTPUT_FILE_PREFIX - Default: 'analysis_'
NB_POSTGRESQL_HOST - Default: 127.0.0.1
NB_POSTGRESQL_DB - Default: pfb
NB_POSTGRESQL_USER - Default: gis
NB_POSTGRESQL_PASSWORD - Default: gis
NB_POSTGRESQL_PORT - Default: 4326

"
}

function ec_export_table_shp() {
    OUTPUT_DIR="$1"
    EXPORT_TABLENAME="$2"

    FILENAME="${OUTPUT_DIR}/${NB_OUTPUT_FILE_PREFIX}${EXPORT_TABLENAME}.shp"
    pgsql2shp -h "${NB_POSTGRESQL_HOST}" \
              -u "${NB_POSTGRESQL_USER}" \
              -p "${NB_POSTGRESQL_PORT}" \
              -P "${NB_POSTGRESQL_PASSWORD}" \
              -f "${FILENAME}" \
              "${NB_POSTGRESQL_DB}" \
              "${EXPORT_TABLENAME}"
}

function ec_export_table_csv() {
    OUTPUT_DIR="$1"
    EXPORT_TABLENAME="$2"

    FILENAME="${OUTPUT_DIR}/${NB_OUTPUT_FILE_PREFIX}${EXPORT_TABLENAME}.csv"
    psql -h "${NB_POSTGRESQL_HOST}" \
         -U "${NB_POSTGRESQL_USER}" \
         -p "${NB_POSTGRESQL_PORT}" \
         -d "${NB_POSTGRESQL_DB}" \
         -c "COPY ${EXPORT_TABLENAME} TO '${FILENAME}' WITH (FORMAT CSV, HEADER)"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]
then
    if [ "${1:-}" = "--help" ] || [ -z "${1:-}" ]
    then
        ec_usage
    else
        echo "Exporting analysis to ${NB_OUTPUT_DIR}"
        NB_OUTPUT_DIR="${1}"
        mkdir -p "${NB_OUTPUT_DIR}"

        # Export neighborhood_ways as SHP
        ec_export_table_shp "${NB_OUTPUT_DIR}" "neighborhood_ways"

        # Export neighborhood ways as GeoJSON
        # TODO: Add ogr2ogr and try again

        # Export neighborhood_connected_census_blocks as SHP
        ec_export_table_shp "${NB_OUTPUT_DIR}" "neighborhood_connected_census_blocks"

        # Export neighborhood_overall_scores as CSV
        ec_export_table_csv "${NB_OUTPUT_DIR}" "neighborhood_overall_scores"
    fi
fi
