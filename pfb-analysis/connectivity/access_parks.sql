----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
-- set block-based raw numbers
UPDATE  neighborhood_census_blocks
SET     parks_low_stress = (
            SELECT  COUNT(id)
            FROM    neighborhood_parks
            WHERE   EXISTS (
                        SELECT  1
                        FROM    neighborhood_connected_census_blocks
                        WHERE   neighborhood_connected_census_blocks.source_blockid10 = neighborhood_census_blocks.blockid10
                        AND     neighborhood_connected_census_blocks.target_blockid10 = ANY(neighborhood_parks.blockid10)
                        AND     neighborhood_connected_census_blocks.low_stress
                    )
        ),
        parks_high_stress = (
            SELECT  COUNT(id)
            FROM    neighborhood_parks
            WHERE   EXISTS (
                        SELECT  1
                        FROM    neighborhood_connected_census_blocks
                        WHERE   neighborhood_connected_census_blocks.source_blockid10 = neighborhood_census_blocks.blockid10
                        AND     neighborhood_connected_census_blocks.target_blockid10 = ANY(neighborhood_parks.blockid10)
                    )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- set block-based ratio
UPDATE  neighborhood_census_blocks
SET     parks_ratio = CASE  WHEN parks_high_stress IS NULL THEN NULL
                            WHEN parks_high_stress = 0 THEN 0
                            ELSE parks_low_stress::FLOAT / parks_high_stress
                            END;

-- set population shed for each park in the neighborhood
UPDATE  neighborhood_parks
SET     pop_high_stress = (
            SELECT  SUM(cb.pop10)
            FROM    neighborhood_census_blocks cb,
                    neighborhood_connected_census_blocks cbs
            WHERE   cbs.source_blockid10 = cb.blockid10
            AND     cbs.target_blockid10 = ANY(neighborhood_parks.blockid10)
        ),
        pop_low_stress = (
            SELECT  SUM(cb.pop10)
            FROM    neighborhood_census_blocks cb,
                    neighborhood_connected_census_blocks cbs
            WHERE   cbs.source_blockid10 = cb.blockid10
            AND     cbs.target_blockid10 = ANY(neighborhood_parks.blockid10)
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary as b
            WHERE   ST_Intersects(neighborhood_parks.geom_pt,b.geom)
        );

UPDATE  neighborhood_parks
SET     pop_ratio = CASE    WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;
