----------------------------------------
-- Input variables:
--      :max_score - Maximum score value
--      :first - Value of first available destination (if 0 then ignore--a basic ratio is used for the score)
--      :second - Value of second available destination (if 0 then ignore--a basic ratio is used after 1)
--      :third - Value of third available destination (if 0 then ignore--a basic ratio is used after 2)
--      :min_path_length - Minimum distance of continuous path in order to be considered a recreational trail
--      :min_bbox_length - Minimum bounding box size in order to be considered a recrational trail
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
SET     trails_score =  CASE
                        WHEN trails_high_stress IS NULL THEN NULL
                        WHEN trails_high_stress = 0 THEN NULL
                        WHEN trails_low_stress = 0 THEN 0
                        WHEN trails_high_stress = trails_low_stress THEN :max_score
                        WHEN :first = 0 THEN trails_low_stress::FLOAT / trails_high_stress
                        WHEN :second = 0
                            THEN    :first
                                    + ((:max_score - :first) * (trails_low_stress::FLOAT - 1))
                                    / (trails_high_stress - 1)
                        WHEN :third = 0
                            THEN    CASE
                                    WHEN trails_low_stress = 1 THEN :first
                                    WHEN trails_low_stress = 2 THEN :first + :second
                                    ELSE :first + :second
                                            + ((:max_score - :first - :second) * (trails_low_stress::FLOAT - 2))
                                            / (trails_high_stress - 2)
                                    END
                        ELSE        CASE
                                    WHEN trails_low_stress = 1 THEN :first
                                    WHEN trails_low_stress = 2 THEN :first + :second
                                    WHEN trails_low_stress = 3 THEN :first + :second + :third
                                    ELSE :first + :second + :third
                                            + ((:max_score - :first - :second - :third) * (trails_low_stress::FLOAT - 3))
                                            / (trails_high_stress - 3)
                                    END
                        END;
