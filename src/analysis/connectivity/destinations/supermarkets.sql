----------------------------------------
-- INPUTS
-- location: neighborhood
-- proj: :nb_output_srid psql var must be set before running this script,
--       e.g. psql -v nb_output_srid=2163 -f supermarkets.sql
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_supermarkets;

CREATE TABLE generated.neighborhood_supermarkets (
    id SERIAL PRIMARY KEY,
    blockid10 CHARACTER VARYING(15)[],
    osm_id BIGINT,
    supermarket_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    geom_pt geometry(point, :nb_output_srid),
    geom_poly geometry(polygon, :nb_output_srid)
);

-- insert points from polygons
INSERT INTO generated.neighborhood_supermarkets (
    osm_id, supermarket_name, geom_pt, geom_poly
)
SELECT  osm_id,
        name,
        ST_Centroid(way),
        way
FROM    neighborhood_osm_full_polygon
WHERE   shop = 'supermarket';

-- remove subareas that are already covered
DELETE FROM generated.neighborhood_supermarkets
WHERE   EXISTS (
            SELECT  1
            FROM    generated.neighborhood_supermarkets s
            WHERE   ST_Contains(s.geom_poly,neighborhood_supermarkets.geom_poly)
            AND     s.id != generated.neighborhood_supermarkets.id
);

-- index
CREATE INDEX sidx_neighborhood_supermarkets_geomply ON neighborhood_supermarkets USING GIST (geom_poly);
ANALYZE neighborhood_supermarkets (geom_poly);

-- insert points
INSERT INTO generated.neighborhood_supermarkets (
    osm_id, supermarket_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    neighborhood_osm_full_point
WHERE   shop = 'supermarket'
AND     NOT EXISTS (
            SELECT  1
            FROM    neighborhood_supermarkets s
            WHERE   ST_Intersects(s.geom_poly,neighborhood_osm_full_point.way)
        );

-- index
CREATE INDEX sidx_neighborhood_supermarkets_geompt ON neighborhood_supermarkets USING GIST (geom_pt);
ANALYZE generated.neighborhood_supermarkets (geom_pt);

-- set blockid10
UPDATE  generated.neighborhood_supermarkets
SET     blockid10 = array((
            SELECT  cb.blockid10
            FROM    neighborhood_census_blocks cb
            WHERE   ST_Intersects(neighborhood_supermarkets.geom_poly,cb.geom)
            OR      ST_Intersects(neighborhood_supermarkets.geom_pt,cb.geom)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_neighborhood_supermarkets_blockid10 ON neighborhood_supermarkets USING GIN (blockid10);
ANALYZE generated.neighborhood_supermarkets (blockid10);
