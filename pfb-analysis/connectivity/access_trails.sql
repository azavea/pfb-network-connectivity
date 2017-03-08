----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
-- low stress access
UPDATE  neighborhood_census_blocks
SET     trails_low_stress = (
            SELECT  COUNT(path_id)
            FROM    neighborhood_paths
            WHERE   EXISTS (
                        SELECT  1
                        FROM    neighborhood_census_block_roads cbr,
                                neighborhood_reachable_roads_low_stress ls,
                                neighborhood_ways,
                                neighborhood_paths
                        WHERE   cb.source_blockid10 = neighborhood_census_blocks.blockid10
                        AND     cb.target_blockid10 = blocks2.blockid10
                        AND     cb.low_stress
            )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- high stress access
UPDATE  neighborhood_census_blocks
SET     trails_low_stress = (
            SELECT  COUNT(path_id)
            FROM    neighborhood_paths
            WHERE   EXISTS (
                        SELECT  1
                        FROM    neighborhood_census_block_roads cbr,
                                neighborhood_reachable_roads_low_stress ls,
                                neighborhood_ways,
                                neighborhood_paths
                        WHERE   cb.source_blockid10 = neighborhood_census_blocks.blockid10
                        AND     cb.target_blockid10 = blocks2.blockid10
            )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );
