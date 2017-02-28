#!/bin/bash

set -e

NB_POSTGRESQL_DB=pfb
NB_POSTGRESQL_USER=gis
NB_POSTGRESQL_PASSWORD=gis

# Set defaults for overridable configuration params
PFB_WORK_MEM="${PFB_WORK_MEM:-2048MB}"
PFB_CHECKPOINT_COMPLETION="${PFB_CHECKPOINT_COMPLETION:-0.8}"
PFB_MAX_WAL_SIZE="${PFB_MAX_WAL_SIZE:-2GB}"

# Set configuration parameters
su postgres bash -c psql <<EOF
ALTER SYSTEM SET work_mem TO '${PFB_WORK_MEM}';
ALTER SYSTEM SET checkpoint_completion_target TO ${PFB_CHECKPOINT_COMPLETION};
ALTER SYSTEM SET max_wal_size TO '${PFB_MAX_WAL_SIZE}';
EOF

# set up database
su postgres bash -c psql <<EOF
CREATE USER ${NB_POSTGRESQL_USER} WITH PASSWORD '${NB_POSTGRESQL_PASSWORD}';
ALTER USER ${NB_POSTGRESQL_USER} WITH SUPERUSER;
CREATE DATABASE ${NB_POSTGRESQL_DB} WITH OWNER ${NB_POSTGRESQL_USER} ENCODING 'UTF-8';
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
ALTER USER ${NB_POSTGRESQL_USER} SET search_path TO generated,received,scratch,"\$user",tdg,public;
EOF
