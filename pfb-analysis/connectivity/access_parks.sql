----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
-- low stress access
UPDATE  neighborhood_census_blocks
SET     parks_low_stress = (
            SELECT  COUNT(id)
            FROM    neighborhood_parks
            WHERE   EXISTS (
                        SELECT  1
                        FROM    connected_census_blocks
                        JOIN    neighborhood_census_blocks park_cb
                        WHERE   (
                                    ST_Intersects(neighborhood_parks.geom_poly,park_cb.geom)
                                OR  ST_Intersects(neighborhood_parks.geom_pt,park_cb.geom)
                                )
                        AND     


                        FROM    neighborhood_census_block_roads cbr,
                                neighborhood_reachable_roads_low_stress ls,
                                neighborhood_ways,
                                neighborhood_parks
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
SET     parks_low_stress = (
            SELECT  COUNT(id)
            FROM    neighborhood_parks
            WHERE   EXISTS (
                        SELECT  1
                        FROM    neighborhood_census_block_roads cbr,
                                neighborhood_reachable_roads_low_stress ls,
                                neighborhood_ways,
                                neighborhood_parks
                        WHERE   cb.source_blockid10 = neighborhood_census_blocks.blockid10
                        AND     cb.target_blockid10 = blocks2.blockid10
            )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );
