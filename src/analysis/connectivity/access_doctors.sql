----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
-- set block-based raw numbers
UPDATE  neighborhood_census_blocks
SET     doctors_low_stress = (
            SELECT  COUNT(id)
            FROM    neighborhood_doctors
            WHERE   EXISTS (
                        SELECT  1
                        FROM    neighborhood_connected_census_blocks
                        WHERE   neighborhood_connected_census_blocks.source_blockid10 = neighborhood_census_blocks.blockid10
                        AND     neighborhood_connected_census_blocks.target_blockid10 = ANY(neighborhood_doctors.blockid10)
                        AND     neighborhood_connected_census_blocks.low_stress
                    )
        ),
        doctors_high_stress = (
            SELECT  COUNT(id)
            FROM    neighborhood_doctors
            WHERE   EXISTS (
                        SELECT  1
                        FROM    neighborhood_connected_census_blocks
                        WHERE   neighborhood_connected_census_blocks.source_blockid10 = neighborhood_census_blocks.blockid10
                        AND     neighborhood_connected_census_blocks.target_blockid10 = ANY(neighborhood_doctors.blockid10)
                    )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- set block-based score
UPDATE  neighborhood_census_blocks
SET     doctors_score = CASE    WHEN doctors_high_stress IS NULL THEN NULL
                                WHEN doctors_high_stress = 0 THEN NULL
                                WHEN doctors_low_stress = 0 THEN 0
                                WHEN doctors_high_stress = 1 AND doctors_low_stress = 1 THEN 1
                                ELSE 0.5 + (0.5 * (doctors_low_stress::FLOAT - 1)) / (doctors_high_stress - 1)
                                END;

-- set population shed for each doctors destination in the neighborhood
UPDATE  neighborhood_doctors
SET     pop_high_stress = (
            SELECT  SUM(cb.pop10)
            FROM    neighborhood_census_blocks cb,
                    neighborhood_connected_census_blocks cbs
            WHERE   cbs.source_blockid10 = cb.blockid10
            AND     cbs.target_blockid10 = ANY(neighborhood_doctors.blockid10)
        ),
        pop_low_stress = (
            SELECT  SUM(cb.pop10)
            FROM    neighborhood_census_blocks cb,
                    neighborhood_connected_census_blocks cbs
            WHERE   cbs.source_blockid10 = cb.blockid10
            AND     cbs.target_blockid10 = ANY(neighborhood_doctors.blockid10)
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary as b
            WHERE   ST_Intersects(neighborhood_doctors.geom_pt,b.geom)
        );

UPDATE  neighborhood_doctors
SET     pop_score = CASE    WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;
