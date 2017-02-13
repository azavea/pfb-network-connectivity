#!/bin/bash

set -e

NB_POSTGRESQL_DB=pfb
NB_POSTGRESQL_USER=gis
NB_POSTGRESQL_PASSWORD=gis

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

# run job
cd /pfb

# determine coordinate reference system based on input shapefile UTM zone
NB_OUTPUT_SRID="$(./detect_utm_zone.py $PFB_SHPFILE)"

./import.sh $PFB_SHPFILE $PFB_STATE $PFB_STATE_FIPS
./run_connectivity.sh

# print scores (TODO: replace with export script)
psql -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" <<EOF
SELECT * FROM neighborhood_overall_scores;
EOF

# shutdown postgres
kill $POSTGRES_PROC
wait
