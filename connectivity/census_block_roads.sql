----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_census_block_roads;

CREATE TABLE generated.neighborhood_census_block_roads (
    id SERIAL PRIMARY KEY,
    blockid10 VARCHAR(15),
    road_id INT
);

-- build a temporary table with buffered geoms to efficiently get
-- containing roads
CREATE TEMP TABLE tmp_block_buffers (
    id INTEGER PRIMARY KEY,
    blockid10 VARCHAR(15),
    geom geometry(multipolygon,3857)
) ON COMMIT DROP;
INSERT INTO tmp_block_buffers
SELECT id, blockid10, ST_Multi(ST_Buffer(geom,15)) FROM neighborhood_census_blocks; --15 meters ~~ 50 ft
CREATE INDEX tidx_neighborhood_blockgeoms ON tmp_block_buffers USING GIST (geom);
ANALYZE tmp_block_buffers;

-- insert blocks and roads
INSERT INTO generated.neighborhood_census_block_roads (
    blockid10,
    road_id
)
SELECT  blocks.blockid10,
        ways.road_id
FROM    tmp_block_buffers blocks,
        neighborhood_ways ways
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_DWithin(zips.geom, blocks.geom, 3350)    --3350 meters ~~ 11000 ft
            AND     zips.zip_code = '02138'
)
AND     ST_Intersects(blocks.geom,ways.geom)
AND     (
            ST_Contains(blocks.geom,ways.geom)
        OR  ST_Length(
                ST_Intersection(blocks.geom,ways.geom)
            ) > 30                                              --30 meters ~~ 100 ft
        );

CREATE INDEX idx_neighborhood_censblkrds
ON generated.neighborhood_census_block_roads (blockid10,road_id);
ANALYZE generated.neighborhood_census_block_roads;
