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

-- build a temporary table with buffered geoms to efficiently get
-- containing roads
CREATE TEMP TABLE tmp_block_buffers (
    id INTEGER PRIMARY KEY,
    blockid10 VARCHAR(15),
    geom geometry(multipolygon,2249)
) ON COMMIT DROP;
INSERT INTO tmp_block_buffers
SELECT id, blockid10, ST_Multi(ST_Buffer(geom,50)) FROM cambridge_census_blocks;
CREATE INDEX tidx_cambridge_blockgeoms ON tmp_block_buffers USING GIST (geom);
ANALYZE tmp_block_buffers;

-- insert blocks and roads
INSERT INTO generated.cambridge_census_block_roads (
    blockid10,
    road_id
)
SELECT  blocks.blockid10,
        ways.road_id
FROM    tmp_block_buffers blocks,
        cambridge_ways ways
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_zip_codes zips
            WHERE   ST_DWithin(zips.geom, blocks.geom, 11000)
            AND     zips.zip_code = '02138'
)
AND     ST_Intersects(blocks.geom,ways.geom)
AND     (
            ST_Contains(blocks.geom,ways.geom)
        OR  ST_Length(
                ST_Intersection(blocks.geom,ways.geom)
            ) > 100
        );

CREATE INDEX idx_cambridge_censblkrds
ON generated.cambridge_census_block_roads (blockid10,road_id);
ANALYZE generated.cambridge_census_block_roads;
