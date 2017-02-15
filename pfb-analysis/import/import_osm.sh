#!/usr/bin/env bash

set -e

cd `dirname $0`

NB_POSTGRESQL_HOST="${NB_POSTGRESQL_HOST:-127.0.0.1}"
NB_POSTGRESQL_DB="${NB_POSTGRESQL_DB:-pfb}"
NB_POSTGRESQL_USER="${NB_POSTGRESQL_USER:-gis}"
NB_POSTGRESQL_PASSWORD="${NB_POSTGRESQL_PASSWORD:-gis}"
NB_OUTPUT_SRID="${NB_OUTPUT_SRID:-4326}"

# drop old tables
echo 'Dropping old tables'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_ways;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_ways_intersections;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_relations_ways;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_nodes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_relations;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_way_classes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_way_tags;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_way_types;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_ways;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_ways_vertices_pgr;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_relations_ways;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_osm_nodes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_osm_relations;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_osm_way_classes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_osm_way_tags;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_osm_way_types;"


# Get the neighborhood_boundary bbox
BBOX_SW_LNG=`psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -t -c "SELECT MIN(ST_Xmin(ST_Transform(geom, 4326))) FROM neighborhood_boundary;"`
BBOX_SW_LAT=`psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -t -c "SELECT MIN(ST_Ymin(ST_Transform(geom, 4326))) FROM neighborhood_boundary;"`
BBOX_NE_LNG=`psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -t -c "SELECT MAX(ST_Xmax(ST_Transform(geom, 4326))) FROM neighborhood_boundary;"`
BBOX_NE_LAT=`psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -t -c "SELECT MAX(ST_Ymax(ST_Transform(geom, 4326))) FROM neighborhood_boundary;"`
# Buffer it
LNG_DIFF=`bc <<< "$BBOX_NE_LNG - $BBOX_SW_LNG"`
LAT_DIFF=`bc <<< "$BBOX_NE_LAT - $BBOX_SW_LAT"`
BBOX_SW_LAT=`bc <<< "$BBOX_SW_LAT - $LAT_DIFF"`
BBOX_SW_LNG=`bc <<< "$BBOX_SW_LNG - $LNG_DIFF"`
BBOX_NE_LAT=`bc <<< "$BBOX_NE_LAT + $LAT_DIFF"`
BBOX_NE_LNG=`bc <<< "$BBOX_NE_LNG + $LNG_DIFF"`
# Download OSM data
OSM_API_URL="http://www.overpass-api.de/api/xapi?*[bbox=${BBOX_SW_LNG},${BBOX_SW_LAT},${BBOX_NE_LNG},${BBOX_NE_LAT}]"
OSM_TEMPDIR=`mktemp -d`
OSM_DATA_FILE="${OSM_TEMPDIR}/overpass.osm"
wget -O "${OSM_DATA_FILE}" "${OSM_API_URL}"

# import the osm with highways
osm2pgrouting \
  -f $OSM_DATA_FILE \
  -h $NB_POSTGRESQL_HOST \
  --dbname ${NB_POSTGRESQL_DB} \
  --username ${NB_POSTGRESQL_USER} \
  --schema received \
  --prefix neighborhood_ \
  --conf ./mapconfig_highway.xml \
  --clean

# import the osm with cycleways that the above misses (bug in osm2pgrouting)
osm2pgrouting \
  -f $OSM_DATA_FILE \
  -h $NB_POSTGRESQL_HOST \
  --dbname ${NB_POSTGRESQL_DB} \
  --username ${NB_POSTGRESQL_USER} \
  --schema scratch \
  --prefix neighborhood_cycwys_ \
  --conf ./mapconfig_cycleway.xml \
  --clean

# rename a few tables
echo 'Renaming tables'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.neighborhood_ways_vertices_pgr RENAME TO neighborhood_ways_intersections;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.neighborhood_ways_intersections RENAME CONSTRAINT vertex_id TO neighborhood_vertex_id;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.osm_nodes RENAME TO neighborhood_osm_nodes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.neighborhood_osm_nodes RENAME CONSTRAINT node_id TO neighborhood_node_id;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.osm_relations RENAME TO neighborhood_osm_relations;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.osm_way_classes RENAME TO neighborhood_osm_way_classes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.neighborhood_osm_way_classes RENAME CONSTRAINT osm_way_classes_pkey TO neighborhood_osm_way_classes_pkey;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.osm_way_tags RENAME TO neighborhood_osm_way_tags;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.osm_way_types RENAME TO neighborhood_osm_way_types;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.neighborhood_osm_way_types RENAME CONSTRAINT osm_way_types_pkey TO neighborhood_osm_way_types_pkey;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.neighborhood_cycwys_ways_vertices_pgr RENAME CONSTRAINT vertex_id TO neighborhood_vertex_id;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.osm_nodes RENAME TO neighborhood_cycwys_osm_nodes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.neighborhood_cycwys_osm_nodes RENAME CONSTRAINT node_id TO neighborhood_node_id;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.osm_relations RENAME TO neighborhood_cycwys_osm_relations;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.osm_way_classes RENAME TO neighborhood_cycwys_osm_way_classes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.neighborhood_cycwys_osm_way_classes RENAME CONSTRAINT osm_way_classes_pkey TO neighborhood_osm_way_classes_pkey;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.osm_way_tags RENAME TO neighborhood_cycwys_osm_way_tags;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.osm_way_types RENAME TO neighborhood_cycwys_osm_way_types;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.neighborhood_cycwys_osm_way_types RENAME CONSTRAINT osm_way_types_pkey TO neighborhood_osm_way_types_pkey;"

# import full osm to fill out additional data needs
# not met by osm2pgrouting

# drop old tables
echo 'Dropping old tables'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_full_line;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_full_point;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_full_polygon;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_full_roads;"

# import
osm2pgsql \
  --host "${NB_POSTGRESQL_HOST}" \
  --username ${NB_POSTGRESQL_USER} \
  --port 5432 \
  --create \
  --database "${NB_POSTGRESQL_DB}" \
  --prefix "neighborhood_osm_full" \
  --proj "${NB_OUTPUT_SRID}" \
  --style ./pfb.style \
  "${OSM_DATA_FILE}"

# Delete downloaded temp OSM data
rm -rf "${OSM_TEMPDIR}"

# move the full osm tables to the received schema
echo 'Moving tables to received schema'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE generated.neighborhood_osm_full_line SET SCHEMA received;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE generated.neighborhood_osm_full_point SET SCHEMA received;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE generated.neighborhood_osm_full_polygon SET SCHEMA received;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE generated.neighborhood_osm_full_roads SET SCHEMA received;"

# process tables
echo 'Updating field names'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
    -v nb_output_srid="${NB_OUTPUT_SRID}" -f ./prepare_tables.sql
echo 'Setting values on road segments'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../features/one_way.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../features/width_ft.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../features/functional_class.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
    -v nb_output_srid="${NB_OUTPUT_SRID}" -f ../features/paths.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../features/speed_limit.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../features/lanes.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../features/park.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../features/bike_infra.sql
echo 'Setting values on intersections'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../features/legs.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../features/signalized.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../features/stops.sql
echo 'Calculating stress'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../stress/stress_motorway-trunk.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../stress/stress_primary.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../stress/stress_secondary.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../stress/stress_tertiary.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../stress/stress_residential.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../stress/stress_living_street.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../stress/stress_track.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../stress/stress_path.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../stress/stress_one_way_reset.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../stress/stress_motorway-trunk_ints.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../stress/stress_primary_ints.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../stress/stress_secondary_ints.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../stress/stress_tertiary_ints.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../stress/stress_lesser_ints.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ../stress/stress_link_ints.sql
