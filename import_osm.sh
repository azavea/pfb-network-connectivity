#!/usr/bin/env bash

# vars
DBHOST='192.168.1.144'
DBNAME='people_for_bikes'
OSMPREFIX='cambridge'
OSMFILE='/home/spencer/gis/cambridge.osm'

# drop old tables
echo 'Dropping old tables'
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS received.${OSMPREFIX}_ways;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS received.${OSMPREFIX}_ways_intersections;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS received.${OSMPREFIX}_relations_ways;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS received.${OSMPREFIX}_osm_nodes;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS received.${OSMPREFIX}_osm_relations;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS received.${OSMPREFIX}_osm_way_classes;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS received.${OSMPREFIX}_osm_way_tags;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS received.${OSMPREFIX}_osm_way_types;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_cycwys_ways;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_cycwys_ways_vertices_pgr;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_cycwys_relations_ways;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_cycwys_osm_nodes;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_cycwys_osm_relations;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_cycwys_osm_way_classes;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_cycwys_osm_way_tags;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_cycwys_osm_way_types;"

# import the osm with highways
osm2pgrouting \
  -f $OSMFILE \
  -h $DBHOST \
  --dbname ${DBNAME} \
  --username gis \
  --schema received \
  --prefix ${OSMPREFIX}_ \
  --conf ./mapconfig_highway.xml \
  --clean

# import the osm with cycleways that the above misses (bug in osm2pgrouting)
osm2pgrouting \
  -f $OSMFILE \
  -h $DBHOST \
  --dbname ${DBNAME} \
  --username gis \
  --schema scratch \
  --prefix ${OSMPREFIX}_cycwys_ \
  --conf ./mapconfig_cycleway.xml \
  --clean

# rename a few tables
echo 'Renaming tables'
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.${OSMPREFIX}_ways_vertices_pgr RENAME TO ${OSMPREFIX}_ways_intersections;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.${OSMPREFIX}_ways_intersections RENAME CONSTRAINT vertex_id TO ${OSMPREFIX}_vertex_id;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.osm_nodes RENAME TO ${OSMPREFIX}_osm_nodes;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.${OSMPREFIX}_osm_nodes RENAME CONSTRAINT node_id TO ${OSMPREFIX}_node_id;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.osm_relations RENAME TO ${OSMPREFIX}_osm_relations;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.osm_way_classes RENAME TO ${OSMPREFIX}_osm_way_classes;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.${OSMPREFIX}_osm_way_classes RENAME CONSTRAINT osm_way_classes_pkey TO ${OSMPREFIX}_osm_way_classes_pkey;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.osm_way_tags RENAME TO ${OSMPREFIX}_osm_way_tags;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.osm_way_types RENAME TO ${OSMPREFIX}_osm_way_types;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.${OSMPREFIX}_osm_way_types RENAME CONSTRAINT osm_way_types_pkey TO ${OSMPREFIX}_osm_way_types_pkey;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE scratch.${OSMPREFIX}_cycwys_ways_vertices_pgr RENAME CONSTRAINT vertex_id TO ${OSMPREFIX}_vertex_id;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE scratch.osm_nodes RENAME TO ${OSMPREFIX}_cycwys_osm_nodes;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE scratch.${OSMPREFIX}_cycwys_osm_nodes RENAME CONSTRAINT node_id TO ${OSMPREFIX}_node_id;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE scratch.osm_relations RENAME TO ${OSMPREFIX}_cycwys_osm_relations;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE scratch.osm_way_classes RENAME TO ${OSMPREFIX}_cycwys_osm_way_classes;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE scratch.${OSMPREFIX}_cycwys_osm_way_classes RENAME CONSTRAINT osm_way_classes_pkey TO ${OSMPREFIX}_osm_way_classes_pkey;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE scratch.osm_way_tags RENAME TO ${OSMPREFIX}_cycwys_osm_way_tags;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE scratch.osm_way_types RENAME TO ${OSMPREFIX}_cycwys_osm_way_types;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE scratch.${OSMPREFIX}_cycwys_osm_way_types RENAME CONSTRAINT osm_way_types_pkey TO ${OSMPREFIX}_osm_way_types_pkey;"

# import full osm to fill out additional data needs
# not met by osm2pgrouting

# drop old tables
echo 'Dropping old tables'
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS received.${OSMPREFIX}_osm_full_line;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS received.${OSMPREFIX}_osm_full_point;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS received.${OSMPREFIX}_osm_full_polygon;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS received.${OSMPREFIX}_osm_full_roads;"

# import
osm2pgsql \
  --host $DBHOST \
  --username gis \
  --port 5432 \
  --create \
  --database ${DBNAME} \
  --prefix ${OSMPREFIX}_osm_full \
  --proj 2249 \
  --style /home/spencer/dev/pfb/pfb.style \
  $OSMFILE

# move the full osm tables to the received schema
echo 'Moving tables to received schema'
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE generated.${OSMPREFIX}_osm_full_line SET SCHEMA received;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE generated.${OSMPREFIX}_osm_full_point SET SCHEMA received;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE generated.${OSMPREFIX}_osm_full_polygon SET SCHEMA received;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE generated.${OSMPREFIX}_osm_full_roads SET SCHEMA received;"

# process tables
echo 'Updating field names'
psql -h $DBHOST -U gis -d ${DBNAME} -f ./prepare_tables.sql
echo 'Setting values on road segments'
psql -h $DBHOST -U gis -d ${DBNAME} -f ./one_way.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./width_ft.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./functional_class.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./paths.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./speed_limit.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./lanes.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./park.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./bike_infra.sql
echo 'Setting values on intersections'
psql -h $DBHOST -U gis -d ${DBNAME} -f ./legs.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./signalized.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stops.sql
echo 'Calculating stress'
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stress_motorway-trunk.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stress_primary.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stress_secondary.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stress_tertiary.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stress_residential.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stress_living_street.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stress_track.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stress_path.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stress_one_way_reset.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stress_motorway-trunk_ints.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stress_primary_ints.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stress_secondary_ints.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stress_tertiary_ints.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stress_lesser_ints.sql
psql -h $DBHOST -U gis -d ${DBNAME} -f ./stress_link_ints.sql
