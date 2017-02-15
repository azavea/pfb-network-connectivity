#!/bin/bash

set -e

NB_POSTGRESQL_DB=pfb
NB_POSTGRESQL_USER=gis
NB_POSTGRESQL_PASSWORD=gis

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
