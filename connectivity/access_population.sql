----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
            AND     zips.zip_code = '02138'

-- low stress access





UPDATE  cambridge_census_blocks
SET     pop_low_stress = (
            SELECT  SUM(pop10)
            FROM
        )


        blocks.source_blockid10,
        blocks.target_blockid10,


        source_block.blockid10 AS source_blockid10,
        target_block.id AS target_id,
        target_block.blockid10 AS target_blockid10,
        target_block.pop10 AS target_pop
FROM    cambridge_census_blocks source_block,
        cambridge_census_blocks target_block
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_census_block_roads source_br,
                    cambridge_census_block_roads target_br,
                    cambridge_reachable_roads_low_stress ls
            WHERE   source_block.blockid10 = source_br.blockid10
            AND     target_block.blockid10 = target_br.blockid10
            AND     ls.base_road = source_br.road_id
            AND     ls.target_road = target_br.road_id
        )
AND     (
            SELECT  MIN(total_cost)
            FROM    cambridge_census_block_roads source_br,
                    cambridge_census_block_roads target_br,
                    cambridge_reachable_roads_low_stress ls
            WHERE   source_block.blockid10 = source_br.blockid10
            AND     target_block.blockid10 = target_br.blockid10
            AND     ls.base_road = source_br.road_id
            AND     ls.target_road = target_br.road_id
        ) /
        (
            SELECT  MIN(total_cost) + 1
            FROM    cambridge_census_block_roads source_br,
                    cambridge_census_block_roads target_br,
                    cambridge_reachable_roads_high_stress hs
            WHERE   source_block.blockid10 = source_br.blockid10
            AND     target_block.blockid10 = target_br.blockid10
            AND     hs.base_road = source_br.road_id
            AND     hs.target_road = target_br.road_id
        ) <= 1.3                                                --30% max deviation
-- and source_block.blockid10 = '250173540002000'
