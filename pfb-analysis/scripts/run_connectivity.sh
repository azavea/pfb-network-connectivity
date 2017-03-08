#!/usr/bin/env bash

set -e

export SHELL  # makes 'parallel' stop complaining about $SHELL being unset

cd `dirname $0`

NB_POSTGRESQL_HOST="${NB_POSTGRESQL_HOST:-127.0.0.1}"
NB_POSTGRESQL_DB="${NB_POSTGRESQL_DB:-pfb}"
NB_POSTGRESQL_USER="${NB_POSTGRESQL_USER:-gis}"
NB_POSTGRESQL_PASSWORD="${NB_POSTGRESQL_PASSWORD:-gis}"
NB_OUTPUT_SRID="${NB_OUTPUT_SRID:-4326}"
NB_BOUNDARY_BUFFER="${NB_BOUNDARY_BUFFER:-0}"

psql -h "${DBHOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -c "SELECT tdgMakeNetwork('neighborhood_ways');"

psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -c "SELECT tdgNetworkCostFromDistance('neighborhood_ways');"

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/census_blocks.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -f ../connectivity/census_block_roads.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -f ../connectivity/reachable_roads_high_stress_prep.sql

/usr/bin/time -v parallel<<EOF
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=0 -f ../connectivity/reachable_roads_high_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=1 -f ../connectivity/reachable_roads_high_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=2 -f ../connectivity/reachable_roads_high_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=3 -f ../connectivity/reachable_roads_high_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=4 -f ../connectivity/reachable_roads_high_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=5 -f ../connectivity/reachable_roads_high_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=6 -f ../connectivity/reachable_roads_high_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=7 -f ../connectivity/reachable_roads_high_stress_calc.sql
EOF

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -f ../connectivity/reachable_roads_high_stress_cleanup.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/reachable_roads_low_stress_prep.sql

/usr/bin/time -v parallel<<EOF
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=0 -f ../connectivity/reachable_roads_low_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=1 -f ../connectivity/reachable_roads_low_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=2 -f ../connectivity/reachable_roads_low_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=3 -f ../connectivity/reachable_roads_low_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=4 -f ../connectivity/reachable_roads_low_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=5 -f ../connectivity/reachable_roads_low_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=6 -f ../connectivity/reachable_roads_low_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=7 -f ../connectivity/reachable_roads_low_stress_calc.sql
EOF

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/reachable_roads_low_stress_cleanup.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" \
  -f ../connectivity/connected_census_blocks.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_population.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/census_block_jobs.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_jobs.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -f ../connectivity/destinations/community_centers.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -f ../connectivity/destinations/medical.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -f ../connectivity/destinations/parks.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -f ../connectivity/destinations/retail.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -f ../connectivity/destinations/schools.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -f ../connectivity/destinations/social_services.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -f ../connectivity/destinations/supermarkets.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" \
  -f ../connectivity/school_roads.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" \
  -f ../connectivity/connected_census_blocks_schools.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_schools.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/overall_scores.sql
