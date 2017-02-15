----------------------------------------
-- INPUTS
-- location: neighborhood
-- Prepares a table to be exported to StreetLightData
----------------------------------------
DROP TABLE IF EXISTS neighborhood_streetlight_destinations;
CREATE TABLE generated.neighborhood_streetlight_destinations (
    id SERIAL PRIMARY KEY,
    geom geometry(multipolygon,4326),
    name TEXT,
    blockid10 TEXT,
    is_pass INT
);

INSERT INTO neighborhood_streetlight_destinations (
    blockid10,
    name,
    geom,
    is_pass
)
SELECT  blocks.blockid10,
        blocks.blockid10,
        -- Transform to 4326, this is what StreetLightData expects
        ST_Transform(blocks.geom,4326),
        0
FROM    neighborhood_census_blocks blocks,
        neighborhood_boundary b
WHERE   ST_Intersects(blocks.geom,b.geom);
