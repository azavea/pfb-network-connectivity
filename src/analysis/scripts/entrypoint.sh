#!/bin/bash

set -e

export NB_POSTGRESQL_DB=pfb
export NB_POSTGRESQL_USER=gis
export NB_POSTGRESQL_PASSWORD=gis

# start postgres and capture the PID
/docker-entrypoint.sh postgres | tee /tmp/postgres_stdout.txt &
POSTGRES_PROC=$!

MAX_TRIES=30
counter=1

# wait for database to become available
while true
do
    echo waiting for database, try ${counter}
    sleep 3
    # don't check if postgres is up until docker-entrypoint gives us the signal
    if grep 'PostgreSQL init process complete' /tmp/postgres_stdout.txt > /dev/null
    then
        set +e
        psql -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -c "SELECT 1" &> /dev/null
        postgresql_status=$?
        set -e
        if [ "$postgresql_status" == "0" ]
        then
            break
        fi
    fi
    if [ "$counter" == "$MAX_TRIES" ]; then
        echo database did not come up successfully
        kill $POSTGRES_PROC
        exit 1
    fi
    ((counter++))
done

PFB_TEMPDIR=`mktemp -d`

# If given a URL for the shapefile, dowload and unzip it. Overrides PFB_SHPFILE.
if [ "${PFB_SHPFILE_URL}" ]
then
    echo "Downloading shapefile"
    pushd "${PFB_TEMPDIR}"
    wget -nv "${PFB_SHPFILE_URL}" -O boundary.zip
    unzip boundary.zip
    PFB_SHPFILE="${PFB_TEMPDIR}"/$(ls *.shp)  # Assumes there's exactly one .shp file
    echo "Boundary shapefile is ${PFB_SHPFILE}"
    popd
fi

# If given a URL for the OSM file, dowload and unzip it. Overrides PFB_OSM_FILE.
if [ "${PFB_OSM_FILE_URL}" ]
then
    echo "Downloading OSM file"
    pushd "${PFB_TEMPDIR}"
    wget -nv "${PFB_OSM_FILE_URL}" -O neighborhood_osm.zip
    unzip neighborhood_osm.zip
    PFB_OSM_FILE="${PFB_TEMPDIR}"/$(ls *.osm)  # Assumes there's exactly one .osm file
    echo "OSM file is ${PFB_OSM_FILE}"
    popd
fi

# run job
cd /opt/pfb/analysis

# determine coordinate reference system based on input shapefile UTM zone
export NB_OUTPUT_SRID="$(./scripts/detect_utm_zone.py $PFB_SHPFILE)"

./scripts/import.sh $PFB_SHPFILE $PFB_STATE $PFB_STATE_FIPS $PFB_OSM_FILE
./scripts/run_connectivity.sh

# print scores (TODO: replace with export script)
psql -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" <<EOF
SELECT * FROM neighborhood_overall_scores;
EOF

NB_OUTPUT_DIR="${NB_OUTPUT_DIR:-$PFB_TEMPDIR}"
./scripts/export_connectivity.sh $NB_OUTPUT_DIR $PFB_JOB_ID

# This will exit immediately when there's no pseudo-TTY but provide a shell if there is,
# so it enables keeping a docker container alive after processing by running it with `-t`
bash

rm -rf "${PFB_TEMPDIR}"

# shutdown postgres
su postgres -c "/usr/lib/postgresql/9.6/bin/pg_ctl stop"
wait
