----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------

SELECT  blocks.id,
        blocks.blockid10,
        (
            SELECT  SUM(b.pop10)
            FROM    cambridge_reachable_roads_low_stress ls,
                    cambridge_census_block_roads br,
                    cambridge_census_blocks b,
            WHERE   blocks.blockid10 =
        ) AS low_stress_pop,

FROM    cambridge_census_blocks blocks




SELECT DISTINCT
        source_block.id,
        source_block.blockid10,
        target_block.id,
        target_block.blockid10,
        target_block.pop10
FROM    cambridge_census_blocks source_block,
        cambridge_census_block_roads source_br,
        cambridge_census_blocks target_block,
        cambridge_census_block_roads target_br
WHERE   source_block.blockid10 = source_br.blockid10
AND     target_block.blockid10 = target_br.blockid10
AND     EXISTS (
            SELECT  1
            FROM    cambridge_reachable_roads_low_stress ls
            WHERE   ls.base_road = source_br.road_id
            AND     ls.target_road = target_br.road_id
)
-- and source_block.id = 88206
