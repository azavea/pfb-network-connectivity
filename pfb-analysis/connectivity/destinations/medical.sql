----------------------------------------
-- INPUTS
-- location: neighborhood
-- proj: :nb_output_srid psql var must be set before running this script,
--       e.g. psql -v nb_output_srid=4326 -f medical.sql
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
    geom_poly geometry(polygon, :nb_output_srid)
);
CREATE INDEX sidx_neighborhood_medical_geompt ON neighborhood_medical USING GIST (geom_pt);
CREATE INDEX sidx_neighborhood_medical_geomply ON neighborhood_medical USING GIST (geom_poly);

-- insert points from polygons
INSERT INTO generated.neighborhood_medical (
    osm_id, medical_name, medical_type, geom_pt, geom_poly
)
SELECT  osm_id,
        name,
        amenity,
        ST_Centroid(way),
        way
FROM    neighborhood_osm_full_polygon
WHERE   amenity IN ('clinic','dentist','doctors','hospital','pharmacy');

-- remove subareas that are part of a larger medical feature
DELETE FROM generated.neighborhood_medical
WHERE   EXISTS (
            SELECT  1
            FROM    generated.neighborhood_medical s
            WHERE   ST_Contains(s.geom_poly,neighborhood_medical.geom_poly)
            AND     s.id != generated.neighborhood_medical.id
);

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
