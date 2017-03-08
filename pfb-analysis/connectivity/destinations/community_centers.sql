----------------------------------------
-- INPUTS
-- location: neighborhood
-- proj: :nb_output_srid psql var must be set before running this script,
--       e.g. psql -v nb_output_srid=4326 -f community_centers.sql
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_community_centers;

CREATE TABLE generated.neighborhood_community_centers (
    id SERIAL PRIMARY KEY,
    osm_id BIGINT,
    center_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    geom_pt geometry(point, :nb_output_srid),
    geom_poly geometry(multipolygon, :nb_output_srid)
);
CREATE INDEX sidx_neighborhood_community_centers_geompt ON neighborhood_community_centers USING GIST (geom_pt);
CREATE INDEX sidx_neighborhood_community_centers_geomply ON neighborhood_community_centers USING GIST (geom_poly);

-- insert polygons
INSERT INTO generated.neighborhood_community_centers (
    geom_poly
)
SELECT  ST_CollectionExtract(unnest(ST_ClusterWithin(way,150)),3)
FROM    neighborhood_osm_full_polygon
WHERE   amenity IN ('community_centre','community_center');

-- set points on polygons
UPDATE  generated.neighborhood_community_centers
SET     geom_pt = ST_Centroid(geom_poly);

-- insert points
INSERT INTO generated.neighborhood_community_centers (
    osm_id, center_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    neighborhood_osm_full_point
WHERE   amenity IN ('community_centre','community_center')
AND     NOT EXISTS (
            SELECT  1
            FROM    neighborhood_community_centers s
            WHERE   ST_Intersects(s.geom_poly,neighborhood_osm_full_point.way)
        );

 ANALYZE generated.neighborhood_community_centers;