----------------------------------------
-- INPUTS
-- location: neighborhood
-- :nb_boundary_buffer psql var must be set before running this script,
-- :nb_output_srid psql var must be set before running this script,
--      e.g. psql -v nb_boundary_buffer=1700 -v nb_output_srid=2163 -f streetlight_gates.sql
----------------------------------------
DROP TABLE IF EXISTS neighborhood_streetlight_gates;
CREATE TABLE generated.neighborhood_streetlight_gates (
    id SERIAL PRIMARY KEY,
    geom geometry(polygon, :nb_output_srid),
    road_id BIGINT,
    functional_class TEXT,
    direction INT,
    is_pass INT
);

INSERT INTO neighborhood_streetlight_gates (
    road_id,
    functional_class,
    geom,
    direction,
    is_pass
)
SELECT  road_id,
        functional_class,
        ST_Buffer(
            ST_SetSRID(
                ST_MakeLine(
                    ST_LineInterpolatePoint(geom,0.5),
                    ST_LineInterpolatePoint(geom,0.55)
                ),
                :nb_output_srid
            ),
            100,
            'endcap=flat'
        ) AS geom,
        degrees(ST_Azimuth(
            ST_LineInterpolatePoint(geom,0.5),
            ST_LineInterpolatePoint(geom,0.55)
        )),
        1
FROM    neighborhood_ways
WHERE   functional_class IN ('primary','secondary','tertiary','residential')
AND     EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS nb
            WHERE   ST_DWithin(neighborhood_ways.geom,nb.geom, :nb_boundary_buffer)
        );

-- formatting for upload to SLD
SELECT  road_id AS id,
        road_id AS name,
        is_pass,
        direction,
        geom
FROM    neighborhood_streetlight_gates;
