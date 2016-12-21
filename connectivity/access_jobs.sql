----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
-- low stress access
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
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- high stress access
UPDATE  neighborhood_census_blocks
SET     emp_high_stress = (
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
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );
