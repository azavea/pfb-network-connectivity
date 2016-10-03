----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
DROP TABLE IF EXISTS generated.cambridge_connected_census_blocks;

CREATE TABLE generated.cambridge_connected_census_blocks (
    id SERIAL PRIMARY KEY,
    source_blockid10 VARCHAR(15),
    target_blockid10 VARCHAR(15),
    low_stress BOOLEAN,
    low_stress_cost INT,
    high_stress BOOLEAN,
    high_stress_cost INT
);

INSERT INTO generated.cambridge_connected_census_blocks (  -- took 2 hrs on the server
    source_blockid10, target_blockid10, low_stress, high_stress
)
SELECT  source_block.blockid10,
        target_block.blockid10,
        'f'::BOOLEAN,
        't'::BOOLEAN
FROM    cambridge_census_blocks source_block,
        cambridge_census_blocks target_block
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_zip_codes zips
            WHERE   ST_Intersects(source_block.geom,zips.geom)
            AND     zips.zip_code = '02138'
        )
AND     source_block.geom <#> target_block.geom < 11000
AND     EXISTS (
            SELECT  1
            FROM    cambridge_census_block_roads source_br,
                    cambridge_census_block_roads target_br,
                    cambridge_reachable_roads_high_stress hs
            WHERE   source_block.blockid10 = source_br.blockid10
            AND     target_block.blockid10 = target_br.blockid10
            AND     hs.base_road = source_br.road_id
            AND     hs.target_road = target_br.road_id
        );

-- block pair index
CREATE INDEX idx_cambridge_blockpairs
ON cambridge_connected_census_blocks (source_blockid10,target_blockid10);
ANALYZE cambridge_connected_census_blocks (source_blockid10,target_blockid10);

-- low stress
UPDATE  cambridge_connected_census_blocks
SET     low_stress = 't'::BOOLEAN
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_census_block_roads source_br,
                    cambridge_census_block_roads target_br,
                    cambridge_reachable_roads_low_stress ls
            WHERE   source_blockid10 = source_br.blockid10
            AND     target_blockid10 = target_br.blockid10
            AND     ls.base_road = source_br.road_id
            AND     ls.target_road = target_br.road_id
        )
AND     (
            SELECT  MIN(total_cost)
            FROM    cambridge_census_block_roads source_br,
                    cambridge_census_block_roads target_br,
                    cambridge_reachable_roads_low_stress ls
            WHERE   source_blockid10 = source_br.blockid10
            AND     target_blockid10 = target_br.blockid10
            AND     ls.base_road = source_br.road_id
            AND     ls.target_road = target_br.road_id
        )::FLOAT /
        COALESCE((
            SELECT  MIN(total_cost) + 1
            FROM    cambridge_census_block_roads source_br,
                    cambridge_census_block_roads target_br,
                    cambridge_reachable_roads_high_stress hs
            WHERE   source_blockid10 = source_br.blockid10
            AND     target_blockid10 = target_br.blockid10
            AND     hs.base_road = source_br.road_id
            AND     hs.target_road = target_br.road_id
        ),11000) <= 1.3;

-- stress index
CREATE INDEX idx_cambridge_blockpairs_lstress ON cambridge_connected_census_blocks (low_stress);
CREATE INDEX idx_cambridge_blockpairs_hstress ON cambridge_connected_census_blocks (high_stress);
ANALYZE cambridge_connected_census_blocks (low_stress,high_stress);
