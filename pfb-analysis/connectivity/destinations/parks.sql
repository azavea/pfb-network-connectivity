----------------------------------------
-- INPUTS
-- location: neighborhood
-- proj: :nb_output_srid psql var must be set before running this script,
-- :cluster_tolerance psql var must be set before running this script.
--       e.g. psql -v nb_output_srid=4326 cluster_tolerance=150 -f parks.sql
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_parks;

CREATE TABLE generated.neighborhood_parks (
    id SERIAL PRIMARY KEY,
    osm_id BIGINT,
    park_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    geom_pt geometry(point, :nb_output_srid),
    geom_poly geometry(multipolygon, :nb_output_srid)
);
CREATE INDEX sidx_neighborhood_parks_geompt ON neighborhood_parks USING GIST (geom_pt);
CREATE INDEX sidx_neighborhood_parks_geomply ON neighborhood_parks USING GIST (geom_poly);

-- insert polygons
INSERT INTO generated.neighborhood_parks (
    geom_poly
)
SELECT  ST_CollectionExtract(unnest(ST_ClusterWithin(way,:cluster_tolerance)),3)
FROM    neighborhood_osm_full_polygon
WHERE   amenity = 'park'
        OR leisure = 'park'
        OR leisure = 'nature_reserve'
        OR leisure = 'playground';

-- set points on polygons
UPDATE  generated.neighborhood_parks
SET     geom_pt = ST_Centroid(geom_poly);

-- insert points
INSERT INTO generated.neighborhood_parks (
    osm_id, park_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    neighborhood_osm_full_point
WHERE   (
            amenity = 'park'
        OR  leisure = 'park'
        OR  leisure = 'nature_reserve'
        OR  leisure = 'playground'
        )
AND     NOT EXISTS (
            SELECT  1
            FROM    neighborhood_parks s
            WHERE   ST_Intersects(s.geom_poly,neighborhood_osm_full_point.way)
        );

ANALYZE generated.neighborhood_parks;
