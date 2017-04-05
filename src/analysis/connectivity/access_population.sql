----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
-- low stress access
UPDATE  neighborhood_census_blocks
SET     pop_low_stress = (
            SELECT  SUM(blocks2.pop10)
            FROM    neighborhood_census_blocks blocks2
            WHERE   EXISTS (
                        SELECT  1
                        FROM    neighborhood_connected_census_blocks cb
                        WHERE   cb.source_blockid10 = neighborhood_census_blocks.blockid10
                        AND     cb.target_blockid10 = blocks2.blockid10
                        AND     cb.low_stress
            )
        ),
        pop_high_stress = (
            SELECT  SUM(blocks2.pop10)
            FROM    neighborhood_census_blocks blocks2
            WHERE   EXISTS (
                        SELECT  1
                        FROM    neighborhood_connected_census_blocks cb
                        WHERE   cb.source_blockid10 = neighborhood_census_blocks.blockid10
                        AND     cb.target_blockid10 = blocks2.blockid10
            )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- set score
UPDATE  neighborhood_census_blocks
SET     pop_score = CASE  WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;
