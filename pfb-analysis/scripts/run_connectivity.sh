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
TOLERANCE_COLLEGES="${TOLERANCE_COLLEGES:-300}"         # cluster tolerance given in units of $NB_OUTPUT_SRID
TOLERANCE_COMM_CTR="${TOLERANCE_COMM_CTR:-150}"         # cluster tolerance given in units of $NB_OUTPUT_SRID
TOLERANCE_MEDICAL="${TOLERANCE_MEDICAL:-150}"           # cluster tolerance given in units of $NB_OUTPUT_SRID
TOLERANCE_PARKS="${TOLERANCE_PARKS:-150}"               # cluster tolerance given in units of $NB_OUTPUT_SRID
TOLERANCE_RETAIL="${TOLERANCE_RETAIL:-150}"             # cluster tolerance given in units of $NB_OUTPUT_SRID
TOLERANCE_UNIVERSITIES="${TOLERANCE_UNIVERSITIES:-300}" # cluster tolerance given in units of $NB_OUTPUT_SRID

psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
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
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=0 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_high_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=1 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_high_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=2 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_high_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=3 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_high_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=4 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_high_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=5 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_high_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=6 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_high_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=7 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_high_stress_calc.sql
EOF

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -f ../connectivity/reachable_roads_high_stress_cleanup.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/reachable_roads_low_stress_prep.sql

/usr/bin/time -v parallel<<EOF
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=0 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_low_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=1 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_low_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=2 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_low_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=3 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_low_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=4 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_low_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=5 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_low_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=6 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_low_stress_calc.sql
psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" -v thread_num=8 -v thread_no=7 -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" -f ../connectivity/reachable_roads_low_stress_calc.sql
EOF

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/reachable_roads_low_stress_cleanup.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_boundary_buffer="${NB_BOUNDARY_BUFFER}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -f ../connectivity/connected_census_blocks.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_population.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/census_block_jobs.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_jobs.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -v cluster_tolerance="${TOLERANCE_COLLEGES}" \
  -f ../connectivity/destinations/colleges.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -v cluster_tolerance="${TOLERANCE_COMM_CTR}" \
  -f ../connectivity/destinations/community_centers.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -v cluster_tolerance="${TOLERANCE_MEDICAL}" \
  -f ../connectivity/destinations/medical.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -v cluster_tolerance="${TOLERANCE_PARKS}" \
  -f ../connectivity/destinations/parks.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -v cluster_tolerance="${TOLERANCE_RETAIL}" \
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
  -v nb_output_srid="${NB_OUTPUT_SRID}" \
  -v cluster_tolerance="${TOLERANCE_UNIVERSITIES}" \
  -f ../connectivity/destinations/universities.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_colleges.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_community_centers.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_medical.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_parks.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_retail.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_schools.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_social_services.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_supermarkets.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/access_universities.sql

/usr/bin/time -v psql -h "${NB_POSTGRESQL_HOST}" -U "${NB_POSTGRESQL_USER}" -d "${NB_POSTGRESQL_DB}" \
  -f ../connectivity/overall_scores.sql
