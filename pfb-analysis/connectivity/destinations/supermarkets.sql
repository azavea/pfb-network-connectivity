----------------------------------------
-- INPUTS
-- location: neighborhood
-- proj: :nb_output_srid psql var must be set before running this script,
--       e.g. psql -v nb_output_srid=4326 -f supermarkets.sql
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_supermarkets;

CREATE TABLE generated.neighborhood_supermarkets (
    id SERIAL PRIMARY KEY,
    osm_id BIGINT,
    supermarket_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    geom_pt geometry(point, :nb_output_srid),
    geom_poly geometry(polygon, :nb_output_srid)
);
CREATE INDEX sidx_neighborhood_supermarkets_geompt ON neighborhood_supermarkets USING GIST (geom_pt);
CREATE INDEX sidx_neighborhood_supermarkets_geomply ON neighborhood_supermarkets USING GIST (geom_poly);

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

ANALYZE generated.neighborhood_supermarkets;
