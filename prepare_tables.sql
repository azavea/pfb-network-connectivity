----------------------------------------
-- INPUTS
-- location: cambridge
-- proj: 2249
----------------------------------------

-- add tdg_id field to roads
ALTER TABLE cambridge_ways ADD COLUMN tdg_id TEXT DEFAULT uuid_generate_v4();

-- drop unnecessary columns
ALTER TABLE cambridge_ways DROP COLUMN class_id;
ALTER TABLE cambridge_ways DROP COLUMN length;
ALTER TABLE cambridge_ways DROP COLUMN length_m;
ALTER TABLE cambridge_ways DROP COLUMN x1;
ALTER TABLE cambridge_ways DROP COLUMN y1;
ALTER TABLE cambridge_ways DROP COLUMN x2;
ALTER TABLE cambridge_ways DROP COLUMN y2;
ALTER TABLE cambridge_ways DROP COLUMN cost;
ALTER TABLE cambridge_ways DROP COLUMN reverse_cost;
ALTER TABLE cambridge_ways DROP COLUMN cost_s;
ALTER TABLE cambridge_ways DROP COLUMN reverse_cost_s;
ALTER TABLE cambridge_ways DROP COLUMN rule;
ALTER TABLE cambridge_ways DROP COLUMN maxspeed_forward;
ALTER TABLE cambridge_ways DROP COLUMN maxspeed_backward;
ALTER TABLE cambridge_ways DROP COLUMN source_osm;
ALTER TABLE cambridge_ways DROP COLUMN target_osm;
ALTER TABLE cambridge_ways DROP COLUMN priority;
ALTER TABLE cambridge_ways DROP COLUMN one_way;

ALTER TABLE cambridge_ways_intersections DROP COLUMN cnt;
ALTER TABLE cambridge_ways_intersections DROP COLUMN chk;
ALTER TABLE cambridge_ways_intersections DROP COLUMN ein;
ALTER TABLE cambridge_ways_intersections DROP COLUMN eout;
ALTER TABLE cambridge_ways_intersections DROP COLUMN lon;
ALTER TABLE cambridge_ways_intersections DROP COLUMN lat;

-- change column names
ALTER TABLE cambridge_ways RENAME COLUMN gid TO road_id;
ALTER TABLE cambridge_ways RENAME COLUMN the_geom TO geom;
ALTER TABLE cambridge_ways RENAME COLUMN source TO intersection_from;
ALTER TABLE cambridge_ways RENAME COLUMN target TO intersection_to;

ALTER TABLE cambridge_ways_intersections RENAME COLUMN id TO int_id;
ALTER TABLE cambridge_ways_intersections RENAME COLUMN the_geom TO geom;

-- reproject
ALTER TABLE cambridge_ways ALTER COLUMN geom TYPE geometry(linestring,2249)
USING ST_Transform(geom,2249);
ALTER TABLE cambridge_hwys_ways ALTER COLUMN the_geom TYPE geometry(linestring,2249)
USING ST_Transform(the_geom,2249);
ALTER TABLE cambridge_ways_intersections ALTER COLUMN geom TYPE geometry(point,2249)
USING ST_Transform(geom,2249);

-- add columns
ALTER TABLE cambridge_ways ADD COLUMN functional_class TEXT;
ALTER TABLE cambridge_ways ADD COLUMN speed_limit INT;
ALTER TABLE cambridge_ways ADD COLUMN one_way_car VARCHAR(2);
ALTER TABLE cambridge_ways ADD COLUMN one_way VARCHAR(2);
ALTER TABLE cambridge_ways ADD COLUMN width_ft INT;
ALTER TABLE cambridge_ways ADD COLUMN ft_bike_infra TEXT;
ALTER TABLE cambridge_ways ADD COLUMN tf_bike_infra TEXT;
ALTER TABLE cambridge_ways ADD COLUMN ft_lanes INT;
ALTER TABLE cambridge_ways ADD COLUMN tf_lanes INT;
ALTER TABLE cambridge_ways ADD COLUMN ft_park INT;
ALTER TABLE cambridge_ways ADD COLUMN tf_park INT;
ALTER TABLE cambridge_ways ADD COLUMN ft_seg_stress INT;
ALTER TABLE cambridge_ways ADD COLUMN ft_int_stress INT;
ALTER TABLE cambridge_ways ADD COLUMN tf_seg_stress INT;
ALTER TABLE cambridge_ways ADD COLUMN tf_int_stress INT;

-- indexes
CREATE INDEX idx_cambridge_ways_osm ON cambridge_ways (osm_id);
CREATE INDEX idx_cambridge_ways_ints_osm ON cambridge_ways_intersections (osm_id);
CREATE INDEX idx_cambridge_fullways ON cambridge_osm_full_line (osm_id);
CREATE INDEX idx_cambridge_fullpoints ON cambridge_osm_full_point (osm_id);
ANALYZE cambridge_ways (osm_id,geom);
ANALYZE cambridge_hwys_ways (the_geom);
ANALYZE cambridge_ways_intersections (osm_id);
ANALYZE cambridge_osm_full_line (osm_id);
ANALYZE cambridge_osm_full_point (osm_id);

-- add in highway data that is missing from first osm2pgrouting call
INSERT INTO cambridge_ways (
    name, intersection_from, intersection_to, osm_id, geom
)
SELECT  name,
        (SELECT     i.int_id
        FROM        cambridge_ways_intersections i
        WHERE       i.geom <#> cambridge_hwys_ways.the_geom < 20
        ORDER BY    ST_Distance(ST_StartPoint(cambridge_hwys_ways.the_geom),i.geom) ASC
        LIMIT       1),
        (SELECT     i.int_id
        FROM        cambridge_ways_intersections i
        WHERE       i.geom <#> cambridge_hwys_ways.the_geom < 20
        ORDER BY    ST_Distance(ST_EndPoint(cambridge_hwys_ways.the_geom),i.geom) ASC
        LIMIT       1),
        osm_id,
        the_geom
FROM    cambridge_hwys_ways
WHERE   NOT EXISTS (
            SELECT  1
            FROM    cambridge_ways w2
            WHERE   w2.osm_id = cambridge_hwys_ways.osm_id
);

-- setup intersection table
ALTER TABLE cambridge_ways_intersections ADD COLUMN legs INT;
ALTER TABLE cambridge_ways_intersections ADD COLUMN signalized BOOLEAN;
ALTER TABLE cambridge_ways_intersections ADD COLUMN stops BOOLEAN;
CREATE INDEX idx_cambridge_ints_stop ON cambridge_ways_intersections (signalized,stops);
