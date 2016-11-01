----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_connected_census_blocks;

CREATE TABLE generated.neighborhood_connected_census_blocks (
    id SERIAL PRIMARY KEY,
    source_blockid10 VARCHAR(15),
    target_blockid10 VARCHAR(15),
    low_stress BOOLEAN,
    low_stress_cost INT,
    high_stress BOOLEAN,
    high_stress_cost INT
);

INSERT INTO generated.neighborhood_connected_census_blocks (
    source_blockid10, target_blockid10, low_stress, high_stress
)
SELECT  source_block.blockid10,
        target_block.blockid10,
        'f'::BOOLEAN,
        't'::BOOLEAN
FROM    neighborhood_boundary b
JOIN    neighborhood_census_blocks source_block
        ON  ST_Intersects(source_block.geom,b.geom)
JOIN    neighborhood_census_blocks target_block
        ON  source_block.geom <#> target_block.geom < 11000
JOIN    neighborhood_census_block_roads source_br
        ON  source_block.blockid10 = source_br.blockid10
JOIN    neighborhood_census_block_roads target_br
        ON  target_block.blockid10 = target_br.blockid10
JOIN    neighborhood_reachable_roads_high_stress hs
        ON  hs.base_road = source_br.road_id
        AND hs.target_road = target_br.road_id
GROUP BY source_block.blockid10, target_block.blockid10
;

-- block pair index
CREATE UNIQUE INDEX idx_neighborhood_blockpairs ON neighborhood_connected_census_blocks (source_blockid10,target_blockid10);
ANALYZE neighborhood_connected_census_blocks;

-- low stress
UPDATE  neighborhood_connected_census_blocks
SET     low_stress = 't'::BOOLEAN
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_census_block_roads source_br,
                    neighborhood_census_block_roads target_br,
                    neighborhood_reachable_roads_low_stress ls
            WHERE   source_blockid10 = source_br.blockid10
            AND     target_blockid10 = target_br.blockid10
            AND     ls.base_road = source_br.road_id
            AND     ls.target_road = target_br.road_id
        )
AND     (
            SELECT  MIN(total_cost)
            FROM    neighborhood_census_block_roads source_br,
                    neighborhood_census_block_roads target_br,
                    neighborhood_reachable_roads_low_stress ls
            WHERE   source_blockid10 = source_br.blockid10
            AND     target_blockid10 = target_br.blockid10
            AND     ls.base_road = source_br.road_id
            AND     ls.target_road = target_br.road_id
        )::FLOAT /
        COALESCE((
            SELECT  MIN(total_cost) + 1
            FROM    neighborhood_census_block_roads source_br,
                    neighborhood_census_block_roads target_br,
                    neighborhood_reachable_roads_high_stress hs
            WHERE   source_blockid10 = source_br.blockid10
            AND     target_blockid10 = target_br.blockid10
            AND     hs.base_road = source_br.road_id
            AND     hs.target_road = target_br.road_id
        ),11000) <= 1.3;

-- stress index
CREATE INDEX IF NOT EXISTS idx_neighborhood_blockpairs_lstress ON neighborhood_connected_census_blocks (low_stress);
CREATE INDEX IF NOT EXISTS idx_neighborhood_blockpairs_hstress ON neighborhood_connected_census_blocks (high_stress);
ANALYZE neighborhood_connected_census_blocks;
