----------------------------------------
-- INPUTS
-- location: neighborhood
-- proj: :nb_output_srid psql var must be set before running this script,
--       e.g. psql -v nb_output_srid=2163 -f prepare_tables.sql
----------------------------------------

-- add tdg_id field to roads
ALTER TABLE neighborhood_ways ADD COLUMN tdg_id TEXT DEFAULT uuid_generate_v4();

-- drop unnecessary columns
ALTER TABLE neighborhood_ways DROP COLUMN class_id;
ALTER TABLE neighborhood_ways DROP COLUMN length;
ALTER TABLE neighborhood_ways DROP COLUMN length_m;
ALTER TABLE neighborhood_ways DROP COLUMN x1;
ALTER TABLE neighborhood_ways DROP COLUMN y1;
ALTER TABLE neighborhood_ways DROP COLUMN x2;
ALTER TABLE neighborhood_ways DROP COLUMN y2;
ALTER TABLE neighborhood_ways DROP COLUMN cost;
ALTER TABLE neighborhood_ways DROP COLUMN reverse_cost;
ALTER TABLE neighborhood_ways DROP COLUMN cost_s;
ALTER TABLE neighborhood_ways DROP COLUMN reverse_cost_s;
ALTER TABLE neighborhood_ways DROP COLUMN rule;
ALTER TABLE neighborhood_ways DROP COLUMN maxspeed_forward;
ALTER TABLE neighborhood_ways DROP COLUMN maxspeed_backward;
ALTER TABLE neighborhood_ways DROP COLUMN source_osm;
ALTER TABLE neighborhood_ways DROP COLUMN target_osm;
ALTER TABLE neighborhood_ways DROP COLUMN priority;
ALTER TABLE neighborhood_ways DROP COLUMN one_way;

ALTER TABLE neighborhood_ways_intersections DROP COLUMN cnt;
ALTER TABLE neighborhood_ways_intersections DROP COLUMN chk;
ALTER TABLE neighborhood_ways_intersections DROP COLUMN ein;
ALTER TABLE neighborhood_ways_intersections DROP COLUMN eout;
ALTER TABLE neighborhood_ways_intersections DROP COLUMN lon;
ALTER TABLE neighborhood_ways_intersections DROP COLUMN lat;

-- change column names
ALTER TABLE neighborhood_ways RENAME COLUMN gid TO road_id;
ALTER TABLE neighborhood_ways RENAME COLUMN the_geom TO geom;
ALTER TABLE neighborhood_ways RENAME COLUMN source TO intersection_from;
ALTER TABLE neighborhood_ways RENAME COLUMN target TO intersection_to;

ALTER TABLE neighborhood_ways_intersections RENAME COLUMN id TO int_id;
ALTER TABLE neighborhood_ways_intersections RENAME COLUMN the_geom TO geom;

-- reproject
ALTER TABLE neighborhood_ways ALTER COLUMN geom TYPE geometry(linestring,:nb_output_srid)
USING ST_Transform(geom,:nb_output_srid);
ALTER TABLE neighborhood_cycwys_ways ALTER COLUMN the_geom TYPE geometry(linestring,:nb_output_srid)
USING ST_Transform(the_geom,:nb_output_srid);
ALTER TABLE neighborhood_ways_intersections ALTER COLUMN geom TYPE geometry(point,:nb_output_srid)
USING ST_Transform(geom,:nb_output_srid);

-- add columns
ALTER TABLE neighborhood_ways ADD COLUMN functional_class TEXT;
ALTER TABLE neighborhood_ways ADD COLUMN path_id INTEGER;
ALTER TABLE neighborhood_ways ADD COLUMN speed_limit INT;
ALTER TABLE neighborhood_ways ADD COLUMN one_way_car VARCHAR(2);
ALTER TABLE neighborhood_ways ADD COLUMN one_way VARCHAR(2);
ALTER TABLE neighborhood_ways ADD COLUMN width_ft INT;
ALTER TABLE neighborhood_ways ADD COLUMN ft_bike_infra TEXT;
ALTER TABLE neighborhood_ways ADD COLUMN ft_bike_infra_width FLOAT;
ALTER TABLE neighborhood_ways ADD COLUMN tf_bike_infra TEXT;
ALTER TABLE neighborhood_ways ADD COLUMN tf_bike_infra_width FLOAT;
ALTER TABLE neighborhood_ways ADD COLUMN ft_lanes INT;
ALTER TABLE neighborhood_ways ADD COLUMN tf_lanes INT;
ALTER TABLE neighborhood_ways ADD COLUMN ft_cross_lanes INT;
ALTER TABLE neighborhood_ways ADD COLUMN tf_cross_lanes INT;
ALTER TABLE neighborhood_ways ADD COLUMN twltl_cross_lanes INT;
ALTER TABLE neighborhood_ways ADD COLUMN ft_park INT;
ALTER TABLE neighborhood_ways ADD COLUMN tf_park INT;
ALTER TABLE neighborhood_ways ADD COLUMN ft_seg_stress INT;
ALTER TABLE neighborhood_ways ADD COLUMN ft_int_stress INT;
ALTER TABLE neighborhood_ways ADD COLUMN tf_seg_stress INT;
ALTER TABLE neighborhood_ways ADD COLUMN tf_int_stress INT;
ALTER TABLE neighborhood_ways ADD COLUMN xwalk INT;

-- indexes
CREATE INDEX idx_neighborhood_ways_osm ON neighborhood_ways (osm_id);
CREATE INDEX idx_neighborhood_ways_ints_osm ON neighborhood_ways_intersections (osm_id);
CREATE INDEX idx_neighborhood_fullways ON neighborhood_osm_full_line (osm_id);
CREATE INDEX idx_neighborhood_fullpoints ON neighborhood_osm_full_point (osm_id);
ANALYZE neighborhood_ways (osm_id,geom);
ANALYZE neighborhood_cycwys_ways (the_geom);
ANALYZE neighborhood_ways_intersections (osm_id);
ANALYZE neighborhood_osm_full_line (osm_id);
ANALYZE neighborhood_osm_full_point (osm_id);

-- add in cycleway data that is missing from first osm2pgrouting call
INSERT INTO neighborhood_ways (
    name, intersection_from, intersection_to, osm_id, geom
)
SELECT  name,
        (SELECT     i.int_id
        FROM        neighborhood_ways_intersections i
        WHERE       i.geom <#> neighborhood_cycwys_ways.the_geom < 20
        ORDER BY    ST_Distance(ST_StartPoint(neighborhood_cycwys_ways.the_geom),i.geom) ASC
        LIMIT       1),
        (SELECT     i.int_id
        FROM        neighborhood_ways_intersections i
        WHERE       i.geom <#> neighborhood_cycwys_ways.the_geom < 20
        ORDER BY    ST_Distance(ST_EndPoint(neighborhood_cycwys_ways.the_geom),i.geom) ASC
        LIMIT       1),
        osm_id,
        the_geom
FROM    neighborhood_cycwys_ways
WHERE   NOT EXISTS (
            SELECT  1
            FROM    neighborhood_ways w2
            WHERE   w2.osm_id = neighborhood_cycwys_ways.osm_id
);

-- setup intersection table
ALTER TABLE neighborhood_ways_intersections ADD COLUMN legs INT;
ALTER TABLE neighborhood_ways_intersections ADD COLUMN signalized BOOLEAN;
ALTER TABLE neighborhood_ways_intersections ADD COLUMN stops BOOLEAN;
ALTER TABLE neighborhood_ways_intersections ADD COLUMN rrfb BOOLEAN;
ALTER TABLE neighborhood_ways_intersections ADD COLUMN island BOOLEAN;

CREATE INDEX idx_neighborhood_ints_stop ON neighborhood_ways_intersections (signalized,stops);
CREATE INDEX idx_neighborhood_rrfb ON neighborhood_ways_intersections (rrfb);
CREATE INDEX idx_neighborhood_island ON neighborhood_ways_intersections (island);
