----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
-- low stress access
UPDATE  neighborhood_census_blocks
SET     pop_low_stress = (
            SELECT  SUM(blocks2.pop10)
            FROM    neighborhood_census_blocks blocks2
            WHERE   EXISTS (
                        SELECT  1
                        FROM    cambridge_connected_census_blocks cb
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
SET     pop_high_stress = (
            SELECT  SUM(blocks2.pop10)
            FROM    neighborhood_census_blocks blocks2
            WHERE   EXISTS (
                        SELECT  1
                        FROM    cambridge_connected_census_blocks cb
                        WHERE   cb.source_blockid10 = neighborhood_census_blocks.blockid10
                        AND     cb.target_blockid10 = blocks2.blockid10
            )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );
