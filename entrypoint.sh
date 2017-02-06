set -e

NB_POSTGRESQL_DB=pfb
NB_POSTGRESQL_USER=gis
NB_POSTGRESQL_PASSWORD=gis

# start postgres and capture the PID
/docker-entrypoint.sh postgres &
POSTGRES_PROC=$!

# sleep while db comes up
sleep 10

# set up database
su postgres bash -c psql <<EOF
CREATE USER gis WITH PASSWORD 'gis';
ALTER USER gis WITH SUPERUSER;
CREATE DATABASE pfb WITH OWNER gis ENCODING 'UTF-8';
EOF

# install extensions
psql -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" <<EOF
CREATE EXTENSION "postgis";
CREATE EXTENSION "uuid-ossp";
CREATE EXTENSION "hstore";
CREATE EXTENSION "plpythonu";
CREATE EXTENSION "pgrouting";
CREATE EXTENSION "quantile";
CREATE EXTENSION "tdg";
ALTER USER gis SET search_path TO generated,received,scratch,"\$user",tdg,public;
EOF

# run job
cd /pfb

./import.sh $PFB_SHPFILE $PFB_STATE $PFB_STATE_FIPS
./run_connectivity.sh

# print scores (TODO: replace with export script)
psql -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" <<EOF
SELECT * FROM neighborhood_overall_scores;
EOF

# shutdown postgres
kill $POSTGRES_PROC
wait
