#!/bin/bash

NB_POSTGRESQL_HOST="${NB_POSTGRESQL_HOST:-127.0.0.1}"
NB_POSTGRESQL_DB="${NB_POSTGRESQL_DB:-pfb}"
NB_POSTGRESQL_USER="${NB_POSTGRESQL_USER:-gis}"
NB_POSTGRESQL_PASSWORD="${NB_POSTGRESQL_PASSWORD:-gis}"


set -e

if [[ -n "${PFB_DEBUG}" ]]; then
    set -x
fi

function usage() {
    echo -n \
"
Usage: $(basename "$0") <state_abbrev>

Import state jobs data into postgres database.

Requires passing the state FIPS abbrev that the neighborhood boundary is found in. e.g. MA for Massachussetts
    See: https://www.census.gov/geo/reference/ansi_statetables.html

Optional ENV vars:

NB_POSTGRESQL_HOST - Default: 127.0.0.1
NB_POSTGRESQL_DB - Default: pfb
NB_POSTGRESQL_USER - Default: gis
NB_POSTGRESQL_PASSWORD - Default: gis

"
}

function import_job_data() {
    NB_TEMPDIR=`mktemp -d`
    NB_STATE_ABBREV="${1}"
    NB_DATA_TYPE="${2-main}"    # Either 'main' or 'aux'
    NB_JOB_FILENAME="${NB_STATE_ABBREV}_od_${NB_DATA_TYPE}_JT00_2014.csv"

    wget -P "${NB_TEMPDIR}" "http://lehd.ces.census.gov/data/lodes/LODES7/${NB_STATE_ABBREV}/od/${NB_JOB_FILENAME}.gz"
    gunzip -c "${NB_TEMPDIR}/${NB_JOB_FILENAME}.gz" > "${NB_TEMPDIR}/${NB_JOB_FILENAME}"

    # Import to postgresql
    psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
        -c "
CREATE TABLE IF NOT EXISTS \"state_od_${NB_DATA_TYPE}_JT00_2014\" (
    w_geocode varchar(15),
    h_geocode varchar(15),
    \"S000\" integer,
    \"SA01\" integer,
    \"SA02\" integer,
    \"SA03\" integer,
    \"SE01\" integer,
    \"SE02\" integer,
    \"SE03\" integer,
    \"SI01\" integer,
    \"SI02\" integer,
    \"SI03\" integer,
    createdate VARCHAR(32)
);"
    psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
        -c "TRUNCATE TABLE \"state_od_${NB_DATA_TYPE}_JT00_2014\";"

    # Load data
    # Dir and files must be world readable/executable for postgres to use copy command
    chmod -R 775 "${NB_TEMPDIR}"
    psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
        -c "COPY \"state_od_${NB_DATA_TYPE}_JT00_2014\"(w_geocode, h_geocode, \"S000\", \"SA01\", \"SA02\", \"SA03\", \"SE01\", \"SE02\", \"SE03\", \"SI01\", \"SI02\", \"SI03\", createdate) FROM '${NB_TEMPDIR}/${NB_JOB_FILENAME}' DELIMITER ',' CSV HEADER;"

    # Remove NB_TEMPDIR
    rm -rf "${NB_TEMPDIR}"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]
then
    if [ "${1:-}" = "--help" ] || [ -z "${1:-}" ]
    then
        usage
    else
        NB_STATE_ABBREV="${1}"

        import_job_data "${NB_STATE_ABBREV}" "main"
        import_job_data "${NB_STATE_ABBREV}" "aux"

    fi
fi
