#!/usr/bin/env bash

cd `dirname $0`

DBHOST='127.0.0.1'
DBNAME='pfb'
OSMPREFIX='cambridge'

# psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
#   -c "SELECT tdgMakeNetwork('${OSMPREFIX}_ways');"

# psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
#   -c "SELECT tdgNetworkCostFromDistance('${OSMPREFIX}_ways');"

/usr/bin/time -v psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
  -f connectivity/census_blocks.sql

/usr/bin/time -v psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
  -f connectivity/census_block_roads.sql

/usr/bin/time -v psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
  -f connectivity/reachable_roads_high_stress.sql

/usr/bin/time -v psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
  -f connectivity/reachable_roads_low_stress.sql

/usr/bin/time -v psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
  -f connectivity/connected_census_blocks.sql

/usr/bin/time -v psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
  -f connectivity/access_population.sql

/usr/bin/time -v psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
  -f connectivity/census_block_jobs.sql

/usr/bin/time -v psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
  -f connectivity/access_jobs.sql

/usr/bin/time -v psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
  -f connectivity/schools.sql

/usr/bin/time -v psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
  -f connectivity/school_roads.sql

/usr/bin/time -v psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
  -f connectivity/school_roads.sql

/usr/bin/time -v psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
  -f connectivity/connected_census_blocks_schools.sql

/usr/bin/time -v psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
  -f connectivity/access_schools.sql

/usr/bin/time -v psql -h "${DBHOST}" -U gis -d "${DBNAME}" \
  -f connectivity/overall_scores.sql
