----------------------------------------
-- INPUTS
-- location: neighborhood
-- proj: :nb_output_srid psql var must be set before running this script,
-- :cluster_tolerance psql var must be set before running this script.
--       e.g. psql -v nb_output_srid=4326 -v cluster_tolerance=150 -f medical.sql
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_medical;

CREATE TABLE generated.neighborhood_medical (
    id SERIAL PRIMARY KEY,
    osm_id BIGINT,
    medical_name TEXT,
    medical_type TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    geom_pt geometry(point, :nb_output_srid),
    geom_poly geometry(multipolygon, :nb_output_srid)
);
CREATE INDEX sidx_neighborhood_medical_geompt ON neighborhood_medical USING GIST (geom_pt);
CREATE INDEX sidx_neighborhood_medical_geomply ON neighborhood_medical USING GIST (geom_poly);

-- insert polygons
INSERT INTO generated.neighborhood_medical (
    geom_poly
)
SELECT  ST_CollectionExtract(unnest(ST_ClusterWithin(way,:cluster_tolerance)),3)
FROM    neighborhood_osm_full_polygon
WHERE   amenity IN ('clinic','dentist','doctors','hospital','pharmacy');

-- set points on polygons
UPDATE  generated.neighborhood_medical
SET     geom_pt = ST_Centroid(geom_poly);

-- insert points
INSERT INTO generated.neighborhood_medical (
    osm_id, medical_name, medical_type, geom_pt
)
SELECT  osm_id,
        name,
        amenity,
        way
FROM    neighborhood_osm_full_point
WHERE   amenity IN ('clinic','dentist','doctors','hospital','pharmacy')
AND     NOT EXISTS (
            SELECT  1
            FROM    neighborhood_medical s
            WHERE   ST_Intersects(s.geom_poly,neighborhood_osm_full_point.way)
        );

ANALYZE generated.neighborhood_medical;
