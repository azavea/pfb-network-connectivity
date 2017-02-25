#!/bin/bash

set -e

NB_POSTGRESQL_DB=pfb
NB_POSTGRESQL_USER=gis
NB_POSTGRESQL_PASSWORD=gis

# Set configuration parameters
su postgres bash -c psql <<EOF
ALTER SYSTEM SET work_mem TO '4096MB';
ALTER SYSTEM SET checkpoint_completion_target TO 0.8;
ALTER SYSTEM SET max_wal_size TO '5GB';
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
