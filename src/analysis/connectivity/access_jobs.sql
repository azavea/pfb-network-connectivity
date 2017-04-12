----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
-- raw numbers
UPDATE  neighborhood_census_blocks
SET     emp_low_stress = (
            SELECT  SUM(blocks2.jobs)
            FROM    neighborhood_census_block_jobs blocks2
            WHERE   EXISTS (
                        SELECT  1
                        FROM    neighborhood_connected_census_blocks cb
                        WHERE   cb.source_blockid10 = neighborhood_census_blocks.blockid10
                        AND     cb.target_blockid10 = blocks2.blockid10
                        AND     cb.low_stress
            )
        ),
        emp_high_stress = (
            SELECT  SUM(blocks2.jobs)
            FROM    neighborhood_census_block_jobs blocks2
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
SET     emp_score = CASE  WHEN emp_high_stress IS NULL THEN NULL
                            WHEN emp_high_stress = 0 THEN 0
                            ELSE emp_low_stress::FLOAT / emp_high_stress
                            END;
