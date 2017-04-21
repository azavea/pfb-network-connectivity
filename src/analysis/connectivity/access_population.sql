----------------------------------------
-- Input variables:
--      :max_score - Maximum score value
--      :step1 - First scoring step
--      :score1 - Score for first step
--      :step2 - Second scoring step
--      :score2 - Score for second step
--      :step3 - Third scoring step
--      :score3 - Score for third step
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
SET     pop_score = CASE
                    WHEN pop_high_stress IS NULL THEN NULL
                    WHEN pop_high_stress = 0 THEN NULL
                    WHEN pop_low_stress = 0 THEN 0
                    WHEN pop_high_stress = pop_low_stress THEN :max_score
                    WHEN :step1 = 0 THEN :max_score * pop_low_stress::FLOAT / pop_high_stress
                    WHEN pop_low_stress::FLOAT / pop_high_stress = :step3 THEN :score3
                    WHEN pop_low_stress::FLOAT / pop_high_stress = :step2 THEN :score2
                    WHEN pop_low_stress::FLOAT / pop_high_stress = :step1 THEN :score1
                    WHEN pop_low_stress::FLOAT / pop_high_stress > :step3
                        THEN    :score3
                                + (:max_score - :score3)
                                * (
                                    (pop_low_stress::FLOAT / pop_high_stress - :step3)
                                    / (1 - :step3)
                                )
                    WHEN pop_low_stress::FLOAT / pop_high_stress > :step2
                        THEN    :score2
                                + (:score3 - :score2)
                                * (
                                    (pop_low_stress::FLOAT / pop_high_stress - :step2)
                                    / (:step3 - :step2)
                                )
                    WHEN pop_low_stress::FLOAT / pop_high_stress > :step1
                        THEN    :score1
                                + (:score2 - :score1)
                                * (
                                    (pop_low_stress::FLOAT / pop_high_stress - :step1)
                                    / (:step2 - :step1)
                                )
                    ELSE        :score1
                                * (
                                    (pop_low_stress::FLOAT / pop_high_stress)
                                    / :step1
                                )
                    END;
