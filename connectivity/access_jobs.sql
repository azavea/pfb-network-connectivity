----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
-- low stress access
UPDATE  cambridge_census_blocks
SET     emp_low_stress = (
            SELECT  SUM(blocks2.jobs)
            FROM    cambridge_census_block_jobs blocks2
            WHERE   EXISTS (
                        SELECT  1
                        FROM    cambridge_connected_census_blocks cb
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

-- high stress access
UPDATE  cambridge_census_blocks
SET     emp_high_stress = (
            SELECT  SUM(blocks2.jobs)
            FROM    cambridge_census_block_jobs blocks2
            WHERE   EXISTS (
                        SELECT  1
                        FROM    cambridge_connected_census_blocks cb
                        WHERE   cb.source_blockid10 = cambridge_census_blocks.blockid10
                        AND     cb.target_blockid10 = blocks2.blockid10
            )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_zip_codes zips
            WHERE   ST_Intersects(cambridge_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );
