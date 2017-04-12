----------------------------------------
-- INPUTS
-- location: neighborhood
-- proj: :nb_output_srid psql var must be set before running this script,
--       e.g. psql -v nb_output_srid=2163 -f social_services.sql
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_social_services;

CREATE TABLE generated.neighborhood_social_services (
    id SERIAL PRIMARY KEY,
    blockid10 CHARACTER VARYING(15)[],
    osm_id BIGINT,
    service_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    geom_pt geometry(point, :nb_output_srid),
    geom_poly geometry(polygon, :nb_output_srid)
);

-- insert points from polygons
INSERT INTO generated.neighborhood_social_services (
    osm_id, service_name, geom_pt, geom_poly
)
SELECT  osm_id,
        name,
        ST_Centroid(way),
        way
FROM    neighborhood_osm_full_polygon
WHERE   amenity = 'social_facility';

-- remove subareas that are already covered
DELETE FROM generated.neighborhood_social_services
WHERE   EXISTS (
            SELECT  1
            FROM    generated.neighborhood_social_services s
            WHERE   ST_Contains(s.geom_poly,neighborhood_social_services.geom_poly)
            AND     s.id != generated.neighborhood_social_services.id
);

-- index
CREATE INDEX sidx_neighborhood_social_services_geomply ON neighborhood_social_services USING GIST (geom_poly);
ANALYZE neighborhood_social_services (geom_poly);

-- insert points
INSERT INTO generated.neighborhood_social_services (
    osm_id, service_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    neighborhood_osm_full_point
WHERE   amenity = 'social_facility'
AND     NOT EXISTS (
            SELECT  1
            FROM    neighborhood_social_services s
            WHERE   ST_Intersects(s.geom_poly,neighborhood_osm_full_point.way)
        );

-- index
CREATE INDEX sidx_neighborhood_social_services_geompt ON neighborhood_social_services USING GIST (geom_pt);
ANALYZE generated.neighborhood_social_services (geom_pt);

-- set blockid10
UPDATE  generated.neighborhood_social_services
SET     blockid10 = array((
            SELECT  cb.blockid10
            FROM    neighborhood_census_blocks cb
            WHERE   ST_Intersects(neighborhood_social_services.geom_poly,cb.geom)
            OR      ST_Intersects(neighborhood_social_services.geom_pt,cb.geom)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_neighborhood_social_services_blockid10 ON neighborhood_social_services USING GIN (blockid10);
ANALYZE generated.neighborhood_social_services (blockid10);
