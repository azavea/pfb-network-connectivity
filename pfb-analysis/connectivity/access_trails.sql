----------------------------------------
-- INPUTS
-- location: neighborhood
-- :min_path_length and :min_bbox_length must
-- be set before running this script
--       e.g. psql -v nb_output_srid=2163 -v min_path_length=4800 -v min_bbox_length=3300 -f access_trails.sql
----------------------------------------
-- low stress access
UPDATE  neighborhood_census_blocks
SET     trails_low_stress = (
            SELECT  COUNT(path_id)
            FROM    neighborhood_paths
            WHERE   path_length > :min_path_length
            AND     bbox_length > :min_bbox_length
            AND     EXISTS (
                        SELECT  1
                        FROM    neighborhood_reachable_roads_low_stress ls
                        JOIN    neighborhood_census_block_roads cbr
                                ON ls.base_road = cbr.road_id
                                AND neighborhood_census_blocks.blockid10 = cbr.blockid10
                        WHERE   ls.target_road = ANY(neighborhood_paths.road_ids)
            )
        ),
        trails_high_stress = (
            SELECT  COUNT(path_id)
            FROM    neighborhood_paths
            WHERE   path_length > :min_path_length
            AND     bbox_length > :min_bbox_length
            AND     EXISTS (
                        SELECT  1
                        FROM    neighborhood_reachable_roads_high_stress hs
                        JOIN    neighborhood_census_block_roads cbr
                                ON hs.base_road = cbr.road_id
                                AND neighborhood_census_blocks.blockid10 = cbr.blockid10
                        WHERE   hs.target_road = ANY(neighborhood_paths.road_ids)
            )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- set block-based ratio
UPDATE  neighborhood_census_blocks
SET     trails_ratio = CASE WHEN trails_high_stress IS NULL THEN NULL
                            WHEN trails_high_stress = 0 THEN 0
                            ELSE trails_low_stress::FLOAT / trails_high_stress
                            END;
