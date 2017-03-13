----------------------------------------
-- INPUTS
-- location: neighborhood
-- proj: :nb_output_srid psql var must be set before running this script,
-- :cluster_tolerance psql var must be set before running this script.
--       e.g. psql -v nb_output_srid=2163 -v cluster_tolerance=50 -f medical.sql
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_medical;

CREATE TABLE generated.neighborhood_medical (
    id SERIAL PRIMARY KEY,
    blockid10 CHARACTER VARYING(15)[],
    osm_id BIGINT,
    medical_name TEXT,
    medical_type TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_ratio FLOAT,
    geom_pt geometry(point, :nb_output_srid),
    geom_poly geometry(multipolygon, :nb_output_srid)
);

-- insert polygons
INSERT INTO generated.neighborhood_medical (
    geom_poly
)
SELECT  ST_Multi(ST_Buffer(ST_CollectionExtract(unnest(ST_ClusterWithin(way,:cluster_tolerance)),3),0))
FROM    neighborhood_osm_full_polygon
WHERE   amenity IN ('clinic','dentist','doctors','hospital','pharmacy');

-- set points on polygons
UPDATE  generated.neighborhood_medical
SET     geom_pt = ST_Centroid(geom_poly);

-- index
CREATE INDEX sidx_neighborhood_medical_geomply ON neighborhood_medical USING GIST (geom_poly);
ANALYZE neighborhood_medical (geom_poly);

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

-- index
CREATE INDEX sidx_neighborhood_medical_geompt ON neighborhood_medical USING GIST (geom_pt);
ANALYZE generated.neighborhood_medical (geom_pt);

-- set blockid10
UPDATE  generated.neighborhood_medical
SET     blockid10 = array((
            SELECT  cb.blockid10
            FROM    neighborhood_census_blocks cb
            WHERE   ST_Intersects(neighborhood_medical.geom_poly,cb.geom)
            OR      ST_Intersects(neighborhood_medical.geom_pt,cb.geom)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_neighborhood_medical_blockid10 ON neighborhood_medical USING GIN (blockid10);
ANALYZE generated.neighborhood_medical (blockid10);
