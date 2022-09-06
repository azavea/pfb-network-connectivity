#!/bin/bash

set -e

export NB_POSTGRESQL_HOST="${NB_POSTGRESQL_HOST:-localhost}"
export NB_POSTGRESQL_DB="${NB_POSTGRESQL_DB:-pfb}"
export NB_POSTGRESQL_USER="${NB_POSTGRESQL_USER:-gis}"

# NB_MAX_TRIP_DISTANCE should be in the same units of the NB_OUTPUT_SRID projection
# Typically meters because we autodetect and use UTM zones
export NB_MAX_TRIP_DISTANCE="${NB_MAX_TRIP_DISTANCE:-2680}"
# Same units as NB_MAX_TRIP_DISTANCE
export NB_BOUNDARY_BUFFER="${NB_BOUNDARY_BUFFER:-$NB_MAX_TRIP_DISTANCE}"
export PFB_POP_URL="${PFB_POP_URL:-}"
export PFB_JOB_URL="${PFB_JOB_URL:-}"
export RUN_IMPORT_JOBS="${RUN_IMPORT_JOBS:-1}"
export PFB_COUNTRY="${PFB_COUNTRY:-USA}"

source "$(dirname $0)"/utils.sh

PFB_TEMPDIR="${NB_TEMPDIR:-$(mktemp -d)}"
mkdir -p "${PFB_TEMPDIR}"

pushd /opt/pfb/analysis

# If given a URL for the shapefile, dowload and unzip it. Overrides PFB_SHPFILE.
if [ "${PFB_SHPFILE_URL}" ]
then
    update_status "IMPORTING" "Downloading shapefile"
    mkdir -p "${PFB_TEMPDIR}/boundary"
    pushd "${PFB_TEMPDIR}/boundary"
    wget -nv "${PFB_SHPFILE_URL}" -O boundary.zip
    unzip boundary.zip
    PFB_SHPFILE="${PFB_TEMPDIR}/boundary"/$(ls *.shp)  # Assumes there's exactly one .shp file
    echo "Boundary shapefile is ${PFB_SHPFILE}"
    popd
fi

# If given a URL for the OSM file, dowload and unzip it. Overrides PFB_OSM_FILE.
if [ "${PFB_OSM_FILE_URL}" ]
then
    update_status "IMPORTING" "Downloading OSM file"
    mkdir -p "${PFB_TEMPDIR}/osm"
    pushd "${PFB_TEMPDIR}/osm"
    wget -nv "${PFB_OSM_FILE_URL}"

    PFB_OSM_FILE_ZIPPED="${PFB_TEMPDIR}/osm"/$(ls *.osm.* || true)
    echo "Zipped OSM file is ${PFB_OSM_FILE_ZIPPED}"
    case "${PFB_OSM_FILE_ZIPPED}" in
        *.bz2)     bunzip2 "${PFB_OSM_FILE_ZIPPED}" ;;
        *.gz)      gunzip "${PFB_OSM_FILE_ZIPPED}" ;;
        *.zip)     unzip "${PFB_OSM_FILE_ZIPPED}" ;;
        *)         echo "Unrecognized zip format, skipping..." ;;
    esac

    PFB_OSM_FILE="${PFB_TEMPDIR}/osm"/$(ls *.osm*)  # Assumes there's exactly one .osm file
    echo "OSM file is ${PFB_OSM_FILE}"
    popd
elif [ ! "${PFB_OSM_FILE}" ] || [ ! -f "${PFB_OSM_FILE}" ]
then
    echo "Downloading OSM extract"
    if [ -n "${AWS_STORAGE_BUCKET_NAME}" ]
    then
        BUCKET_ARG="--storage_bucket ${AWS_STORAGE_BUCKET_NAME}"
    else
        BUCKET_ARG=""
    fi
    if [ -n "${PFB_STATE}" ]
    then
        PFB_STATE_ARG="--state_abbrev ${PFB_STATE}"
    else
        PFB_STATE_ARG=""
    fi
    PFB_OSM_FILE="$(./scripts/download_osm_extract.py $BUCKET_ARG $PFB_STATE_ARG $PFB_TEMPDIR $PFB_COUNTRY)"
fi

# run job

# determine coordinate reference system based on input shapefile UTM zone
export NB_OUTPUT_SRID="$(./scripts/detect_utm_zone.py $PFB_SHPFILE)"
./scripts/import.sh $PFB_SHPFILE $PFB_OSM_FILE $PFB_COUNTRY $PFB_STATE $PFB_STATE_FIPS
./scripts/run_connectivity.sh

# print scores
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" <<EOF
SELECT * FROM neighborhood_overall_scores;
EOF

EXPORT_DIR="${NB_OUTPUT_DIR:-$PFB_TEMPDIR/output}"
if [ -n "${PFB_JOB_ID}" ]
then
    EXPORT_DIR="${EXPORT_DIR}/${PFB_JOB_ID}"
else
    EXPORT_DIR="${EXPORT_DIR}/local-analysis-`date +%F-%H%M`"
fi
./scripts/export_connectivity.sh $EXPORT_DIR

rm -rf "${PFB_TEMPDIR}"

popd
