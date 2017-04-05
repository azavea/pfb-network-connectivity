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
                        WHERE   ls.target_road = ANY(neighborhood_paths.road_ids)
                        AND     ls.base_road = ANY(neighborhood_census_blocks.road_ids)
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
                        WHERE   hs.target_road = ANY(neighborhood_paths.road_ids)
                        AND     hs.base_road = ANY(neighborhood_census_blocks.road_ids)
            )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- set block-based score
UPDATE  neighborhood_census_blocks
SET     trails_score = CASE WHEN trails_high_stress IS NULL THEN NULL
                            WHEN trails_high_stress = 0 THEN NULL
                            WHEN trails_low_stress = 0 THEN 0
                            WHEN trails_high_stress = 1 AND trails_low_stress = 1 THEN 1
                            ELSE 0.5 + (0.5 * (trails_low_stress::FLOAT - 1)) / (trails_high_stress - 1)
                            END;
