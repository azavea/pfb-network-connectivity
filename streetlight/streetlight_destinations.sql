----------------------------------------
-- INPUTS
-- location: cambridge
-- proj: 2249
----------------------------------------
DROP TABLE IF EXISTS cambridge_streetlight_destinations;
CREATE TABLE generated.cambridge_streetlight_destinations (
    id SERIAL PRIMARY KEY,
    geom geometry(multipolygon,4326),
    name TEXT,
    blockid10 TEXT,
    is_pass INT
);

INSERT INTO cambridge_streetlight_destinations (
    blockid10,
    name,
    geom,
    is_pass
)
SELECT  blocks.blockid10,
        blocks.blockid10,
        ST_Transform(blocks.geom,4326),
        0
FROM    cambridge_census_blocks blocks,
        cambridge_zip_codes zips
WHERE   zips.zip_code = '02138'
AND     ST_Intersects(blocks.geom,zips.geom);
