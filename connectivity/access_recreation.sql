----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
-- low stress access
UPDATE  cambridge_census_blocks
SET     rec_low_stress = (
            SELECT  COUNT(path_id)
            FROM    cambridge_paths
            WHERE   EXISTS (
                        SELECT  1
                        FROM    cambridge_census_block_roads cbr,
                                cambridge_reachable_roads_low_stress ls,
                                cambridge_ways,
                                cambridge_paths
                        WHERE   cb.source_blockid10 = cambridge_census_blocks.blockid10
                        AND     cb.target_blockid10 = blocks2.blockid10
                        AND     cb.low_stress
            )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_zip_codes zips
            WHERE   ST_Intersects(cambridge_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );
