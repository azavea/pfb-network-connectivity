# vars
DBHOST='192.168.1.144'
DBNAME='people_for_bikes'
OSMPREFIX='cambridge'
OSMFILE='/home/spencer/Downloads/boston_massachusetts.osm'

# drop old tables
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
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_hwys_ways;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_hwys_ways_vertices_pgr;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_hwys_relations_ways;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_hwys_osm_nodes;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_hwys_osm_relations;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_hwys_osm_way_classes;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_hwys_osm_way_tags;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "DROP TABLE IF EXISTS scratch.${OSMPREFIX}_hwys_osm_way_types;"

# import the osm optimized for routing
osm2pgrouting \
  -f $OSMFILE \
  -h $DBHOST \
  --dbname ${DBNAME} \
  --username gis \
  --schema received \
  --prefix ${OSMPREFIX}_ \
  --conf ./mapconfig_all.xml
  --clean

# import the osm with highways that the above misses (bug in osm2pgrouting)
osm2pgrouting \
  -f $OSMFILE \
  -h $DBHOST \
  --dbname ${DBNAME} \
  --username gis \
  --schema scratch \
  --prefix ${OSMPREFIX}_hwys_ \
  --conf ./mapconfig_highway.xml
  --clean

# rename a few tables
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.${OSMPREFIX}_ways_vertices_pgr RENAME TO ${OSMPREFIX}_ways_intersections;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.osm_nodes RENAME TO ${OSMPREFIX}_osm_nodes;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.osm_relations RENAME TO ${OSMPREFIX}_osm_relations;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.osm_way_classes RENAME TO ${OSMPREFIX}_osm_way_classes;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.osm_way_tags RENAME TO ${OSMPREFIX}_osm_way_tags;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE received.osm_way_types RENAME TO ${OSMPREFIX}_osm_way_types;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE scratch.osm_nodes RENAME TO ${OSMPREFIX}_hwys_osm_nodes;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE scratch.osm_relations RENAME TO ${OSMPREFIX}_hwys_osm_relations;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE scratch.osm_way_classes RENAME TO ${OSMPREFIX}_hwys_osm_way_classes;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE scratch.osm_way_tags RENAME TO ${OSMPREFIX}_hwys_osm_way_tags;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE scratch.osm_way_types RENAME TO ${OSMPREFIX}_hwys_osm_way_types;"

# import full osm to fill out additional data needs
# not met by osm2pgrouting

# drop old tables
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
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE generated.${OSMPREFIX}_osm_full_line SET SCHEMA received;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE generated.${OSMPREFIX}_osm_full_point SET SCHEMA received;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE generated.${OSMPREFIX}_osm_full_polygon SET SCHEMA received;"
psql -h $DBHOST -U gis -d ${DBNAME} \
  -c "ALTER TABLE generated.${OSMPREFIX}_osm_full_roads SET SCHEMA received;"
