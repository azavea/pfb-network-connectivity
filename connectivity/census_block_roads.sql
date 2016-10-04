----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
DROP TABLE IF EXISTS generated.cambridge_census_block_roads;

CREATE TABLE generated.cambridge_census_block_roads (
    id SERIAL PRIMARY KEY,
    blockid10 VARCHAR(15),
    road_id INT
);

INSERT INTO generated.cambridge_census_block_roads (
    blockid10,
    road_id
)
SELECT  blocks.blockid10,
        ways.road_id
FROM    cambridge_census_blocks blocks,
        cambridge_ways ways
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_zip_codes zips
            WHERE   ST_DWithin(zips.geom, blocks.geom, 11000)
            AND     zips.zip_code = '02138'
)
AND     ST_DWithin(blocks.geom,ways.geom,50);

CREATE INDEX idx_cambridge_censblkrds
ON generated.cambridge_census_block_roads (blockid10,road_id);
ANALYZE generated.cambridge_census_block_roads;
