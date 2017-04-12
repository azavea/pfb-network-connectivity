----------------------------------------
-- INPUTS
-- location: neighborhood
-- proj: :nb_output_srid psql var must be set before running this script,
--       e.g. psql -v nb_output_srid=2163 cluster_tolerance=75 -f transit.sql
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_transit;

CREATE TABLE generated.neighborhood_transit (
    id SERIAL PRIMARY KEY,
    blockid10 CHARACTER VARYING(15)[],
    osm_id BIGINT,
    transit_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    geom_pt geometry(point, :nb_output_srid),
    geom_poly geometry(polygon, :nb_output_srid)
);

-- insert points from polygons
INSERT INTO generated.neighborhood_transit (
    osm_id, transit_name, geom_pt, geom_poly
)
SELECT  osm_id,
        name,
        ST_Centroid(way),
        way
FROM    neighborhood_osm_full_polygon
WHERE   amenity = 'bus_station'
OR      railway = 'station'
OR      public_transport = 'station';

-- remove subareas
DELETE FROM generated.neighborhood_transit
WHERE   EXISTS (
            SELECT  1
            FROM    generated.neighborhood_transit s
            WHERE   ST_Contains(s.geom_poly,neighborhood_transit.geom_poly)
            AND     s.id != generated.neighborhood_transit.id
);

-- index
CREATE INDEX sidx_neighborhood_transit_geomply ON neighborhood_transit USING GIST (geom_poly);
ANALYZE generated.neighborhood_transit (geom_poly);

-- insert points
INSERT INTO generated.neighborhood_transit (
    geom_pt
)
SELECT  ST_Centroid(ST_CollectionExtract(unnest(ST_ClusterWithin(way,:cluster_tolerance)),1))
FROM    neighborhood_osm_full_point
WHERE   (
            amenity = 'bus_station'
        OR  railway = 'station'
        OR  public_transport = 'station'
        )
AND     NOT EXISTS (
            SELECT  1
            FROM    neighborhood_transit s
            WHERE   ST_DWithin(s.geom_poly,neighborhood_osm_full_point.way,:cluster_tolerance)
        );

-- index
CREATE INDEX sidx_neighborhood_transit_geompt ON neighborhood_transit USING GIST (geom_pt);
ANALYZE generated.neighborhood_transit (geom_pt);

-- set blockid10
UPDATE  generated.neighborhood_transit
SET     blockid10 = array((
            SELECT  cb.blockid10
            FROM    neighborhood_census_blocks cb
            WHERE   ST_Intersects(neighborhood_transit.geom_poly,cb.geom)
            OR      ST_Intersects(neighborhood_transit.geom_pt,cb.geom)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_neighborhood_transit_blockid10 ON neighborhood_transit USING GIN (blockid10);
ANALYZE generated.neighborhood_transit (blockid10);
