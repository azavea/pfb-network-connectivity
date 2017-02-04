#!/usr/bin/env bash

set -e

cd `dirname $0`

NB_POSTGRESQL_HOST="${NB_POSTGRESQL_HOST:-127.0.0.1}"
NB_POSTGRESQL_DB="${NB_POSTGRESQL_DB:-pfb}"
NB_POSTGRESQL_USER="${NB_POSTGRESQL_USER:-gis}"
NB_POSTGRESQL_PASSWORD="${NB_POSTGRESQL_PASSWORD:-gis}"
NB_POSTGRESQL_PORT="${NB_POSTGRESQL_PORT:-5432}"
NB_OUTPUT_FILE_PREFIX="${NB_OUTPUT_FILE_PREFIX:-analysis_}"

NB_OUTPUT_DIR="${1}"

function usage() {
    echo -n \
"
Usage: $(basename "$0") <output_directory>

Export data from a successful run of the PeopleForBike Network Analysis to a directory on disk.

<output_directory> must be an absolute path (pgsql COPY doesn't support relative paths)

This script exports the following tables:
 - neighborhood_ways as SHP
 - neighborhood_ways as GeoJSON
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
if [ "${BASH_SOURCE[0]}" = "${0}" ]
then
    if [ "${1:-}" = "--help" ] || [ -z "${1:-}" ]
    then
        usage
    else
        NB_OUTPUT_DIR="${1}"

        # Export neighborhood_ways as SHP
        EXPORT_TABLENAME='neighborhood_ways'
        FILETYPE='shp'
        FILENAME="${NB_OUTPUT_DIR}/${NB_OUTPUT_FILE_PREFIX}${EXPORT_TABLENAME}.${FILETYPE}"
        pgsql2shp -h "${NB_POSTGRESQL_HOST}" \
                  -u "${NB_POSTGRESQL_USER}" \
                  -p "${NB_POSTGRESQL_PORT}" \
                  -P "${NB_POSTGRESQL_PASSWORD}" \
                  -f "${FILENAME}" \
                  "${NB_POSTGRESQL_DB}" \
                  "${EXPORT_TABLENAME}"

        # Export neighborhood ways as GeoJSON
        # TODO: Add ogr2ogr and try again

        # Export neighborhood_connected_census_blocks as SHP
        EXPORT_TABLENAME='neighborhood_connected_census_blocks'
        FILETYPE='shp'
        FILENAME="${NB_OUTPUT_DIR}/${NB_OUTPUT_FILE_PREFIX}${EXPORT_TABLENAME}.${FILETYPE}"
        pgsql2shp -h "${NB_POSTGRESQL_HOST}" \
                  -u "${NB_POSTGRESQL_USER}" \
                  -p "${NB_POSTGRESQL_PORT}" \
                  -P "${NB_POSTGRESQL_PASSWORD}" \
                  -f "${FILENAME}" \
                  "${NB_POSTGRESQL_DB}" \
                  "${EXPORT_TABLENAME}"

        # Export neighborhood_overall_scores as CSV
        EXPORT_TABLENAME='neighborhood_overall_scores'
        FILETYPE='csv'
        FILENAME="${NB_OUTPUT_DIR}/${NB_OUTPUT_FILE_PREFIX}${EXPORT_TABLENAME}.${FILETYPE}"
        psql -h "${NB_POSTGRESQL_HOST}" \
             -U "${NB_POSTGRESQL_USER}" \
             -p "${NB_POSTGRESQL_PORT}" \
             -d "${NB_POSTGRESQL_DB}" \
             -c "COPY ${EXPORT_TABLENAME} TO '${FILENAME}' WITH (FORMAT CSV, HEADER)"
    fi
fi
