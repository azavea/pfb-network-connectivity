----------------------------------------
-- INPUTS
-- location: neighborhood
-- proj: :nb_output_srid psql var must be set before running this script,
-- :cluster_tolerance psql var must be set before running this script.
--       e.g. psql -v nb_output_srid=2163 -v cluster_tolerance=50 -f pharmacies.sql
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_pharmacies;

CREATE TABLE generated.neighborhood_pharmacies (
    id SERIAL PRIMARY KEY,
    blockid10 CHARACTER VARYING(15)[],
    osm_id BIGINT,
    pharmacy_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    geom_pt geometry(point, :nb_output_srid),
    geom_poly geometry(multipolygon, :nb_output_srid)
);

-- insert polygons
INSERT INTO generated.neighborhood_pharmacies (
    geom_poly
)
SELECT  ST_Multi(ST_Buffer(ST_CollectionExtract(unnest(ST_ClusterWithin(way,:cluster_tolerance)),3),0))
FROM    neighborhood_osm_full_polygon
WHERE   amenity = 'pharmacy';

-- set points on polygons
UPDATE  generated.neighborhood_pharmacies
SET     geom_pt = ST_Centroid(geom_poly);

-- index
CREATE INDEX sidx_neighborhood_pharmacies_geomply ON neighborhood_pharmacies USING GIST (geom_poly);
ANALYZE neighborhood_pharmacies (geom_poly);

-- insert points
INSERT INTO generated.neighborhood_pharmacies (
    osm_id, pharmacy_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    neighborhood_osm_full_point
WHERE   amenity = 'pharmacy'
AND     NOT EXISTS (
            SELECT  1
            FROM    neighborhood_pharmacies s
            WHERE   ST_Intersects(s.geom_poly,neighborhood_osm_full_point.way)
        );

-- index
CREATE INDEX sidx_neighborhood_pharmacies_geompt ON neighborhood_pharmacies USING GIST (geom_pt);
ANALYZE generated.neighborhood_pharmacies (geom_pt);

-- set blockid10
UPDATE  generated.neighborhood_pharmacies
SET     blockid10 = array((
            SELECT  cb.blockid10
            FROM    neighborhood_census_blocks cb
            WHERE   ST_Intersects(neighborhood_pharmacies.geom_poly,cb.geom)
            OR      ST_Intersects(neighborhood_pharmacies.geom_pt,cb.geom)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_neighborhood_pharmacies_blockid10 ON neighborhood_pharmacies USING GIN (blockid10);
ANALYZE generated.neighborhood_pharmacies (blockid10);
