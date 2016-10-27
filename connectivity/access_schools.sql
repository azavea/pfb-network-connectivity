----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
-- low stress access
UPDATE  neighborhood_census_blocks
SET     schools_low_stress = (
            SELECT  COUNT(cbs.id)
            FROM    neighborhood_connected_census_blocks_schools cbs
            WHERE   cbs.source_blockid10 = neighborhood_census_blocks.blockid10
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary as b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- high stress access
UPDATE  neighborhood_census_blocks
SET     schools_high_stress = (
            SELECT  COUNT(cbs.id)
            FROM    neighborhood_connected_census_blocks_schools cbs
            WHERE   cbs.source_blockid10 = neighborhood_census_blocks.blockid10
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary as b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- low stress population shed for schools in neighborhood
UPDATE  neighborhood_schools
SET     pop_low_stress = (
            SELECT  SUM(cb.pop10)
            FROM    neighborhood_census_blocks cb,
                    neighborhood_connected_census_blocks_schools cbs
            WHERE   cb.blockid10 = cbs.source_blockid10
            AND     neighborhood_schools.id = cbs.target_school_id
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary as b
            WHERE   ST_Intersects(neighborhood_schools.geom_pt,b.geom)
        );

-- high stress population shed for schools in neighborhood
UPDATE  neighborhood_schools
SET     pop_high_stress = (
            SELECT  SUM(cb.pop10)
            FROM    neighborhood_census_blocks cb,
                    neighborhood_connected_census_blocks_schools cbs
            WHERE   cb.blockid10 = cbs.source_blockid10
            AND     neighborhood_schools.id = cbs.target_school_id
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary as b
            WHERE   ST_Intersects(neighborhood_schools.geom_pt,b.geom)
        );
