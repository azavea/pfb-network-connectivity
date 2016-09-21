----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
UPDATE  cambridge_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class IN ('tertiary','tertiary_link');

-- scoring with additional info
UPDATE  cambridge_ways
SET     ft_seg_stress =
            CASE
            WHEN ft_bike_infra = 'track' THEN 1
            WHEN ft_bike_infra = 'buffered_lane'
                    THEN    CASE
                            WHEN speed_limit > 30 THEN 3
                            ELSE    CASE
                                    WHEN ft_lanes > 1 THEN 3
                                    ELSE 1
                                    END
                            END
            WHEN ft_bike_infra = 'lane'
                    THEN    CASE
                            WHEN speed_limit > 30 THEN 3
                            WHEN speed_limit <= 25
                                    THEN    CASE
                                            WHEN ft_lanes > 2 THEN 3
                                            WHEN ft_lanes = 1 THEN  CASE
                                                                    WHEN ft_park = 1 THEN 3
                                                                    ELSE 2
                                                                    END
                                            ELSE    CASE
                                                    WHEN ft_park = 0 THEN 1
                                                    ELSE 2
                                                    END
                                            END
                            ELSE    CASE
                                    WHEN ft_lanes > 1 THEN 3
                                    ELSE    CASE
                                            WHEN ft_park = 0 THEN 1
                                            ELSE 2
                                            END
                                    END
                            END
            ELSE    CASE
                    WHEN speed_limit = 30
                            THEN    CASE
                                    WHEN ft_lanes = 1 THEN 2
                                    ELSE 3
                                    END
                    WHEN speed_limit = 25
                            THEN    CASE
                                    WHEN ft_lanes = 1 THEN 1
                                    ELSE 3
                                    END
                    ELSE 3
                    END
            END
WHERE   functional_class IN ('tertiary','tertiary_link');
UPDATE  cambridge_ways
SET     tf_seg_stress =
            CASE
            WHEN tf_bike_infra = 'track' THEN 1
            WHEN tf_bike_infra = 'buffered_lane'
                    THEN    CASE
                            WHEN speed_limit > 30 THEN 3
                            ELSE    CASE
                                    WHEN tf_lanes > 1 THEN 3
                                    ELSE 1
                                    END
                            END
            WHEN tf_bike_infra = 'lane'
                    THEN    CASE
                            WHEN speed_limit > 30 THEN 3
                            WHEN speed_limit <= 25
                                    THEN    CASE
                                            WHEN tf_lanes > 2 THEN 3
                                            WHEN tf_lanes = 1 THEN  CASE
                                                                    WHEN tf_park = 1 THEN 3
                                                                    ELSE 2
                                                                    END
                                            ELSE    CASE
                                                    WHEN tf_park = 0 THEN 1
                                                    ELSE 2
                                                    END
                                            END
                            ELSE    CASE
                                    WHEN tf_lanes > 1 THEN 3
                                    ELSE    CASE
                                            WHEN tf_park = 0 THEN 1
                                            ELSE 2
                                            END
                                    END
                            END
            ELSE    CASE
                    WHEN speed_limit = 30
                            THEN    CASE
                                    WHEN tf_lanes = 1 THEN 2
                                    ELSE 3
                                    END
                    WHEN speed_limit = 25
                            THEN    CASE
                                    WHEN tf_lanes = 1 THEN 1
                                    ELSE 3
                                    END
                    ELSE 3
                    END
            END
WHERE   functional_class IN ('tertiary','tertiary_link');


--
--
-- -- no additional information
-- UPDATE  cambridge_ways
-- SET     ft_seg_stress = 3,
--         tf_seg_stress = 3
-- WHERE   functional_class IN ('tertiary','tertiary_link');
--
-- -- stress reduction on shared lanes with additional information
-- UPDATE  cambridge_ways
-- SET     ft_seg_stress = 2
-- WHERE   functional_class IN ('tertiary','tertiary_link')
-- AND     ft_bike_infra IS NULL
-- AND     speed_limit <= 30
-- AND     ft_lanes < 2;
-- UPDATE  cambridge_ways
-- SET     ft_seg_stress = 1
-- WHERE   functional_class IN ('tertiary','tertiary_link')
-- AND     ft_bike_infra IS NULL
-- AND     speed_limit <= 25
-- AND     ft_lanes < 2;
--
-- UPDATE  cambridge_ways
-- SET     tf_seg_stress = 2
-- WHERE   functional_class IN ('tertiary','tertiary_link')
-- AND     tf_bike_infra IS NULL
-- AND     speed_limit <= 30
-- AND     tf_lanes < 2;
-- UPDATE  cambridge_ways
-- SET     tf_seg_stress = 1
-- WHERE   functional_class IN ('tertiary','tertiary_link')
-- AND     tf_bike_infra IS NULL
-- AND     speed_limit <= 25
-- AND     tf_lanes < 2;
--
-- -- stress reduction for cycle track
-- UPDATE  cambridge_ways
-- SET     ft_seg_stress = 1
-- WHERE   functional_class IN ('tertiary','tertiary_link')
-- AND     ft_bike_infra = 'track';
-- UPDATE  cambridge_ways
-- SET     tf_seg_stress = 1
-- WHERE   functional_class IN ('tertiary','tertiary_link')
-- AND     tf_bike_infra = 'track';
--
-- -- stress reduction for buffered lane
-- UPDATE  cambridge_ways
-- SET     ft_seg_stress = 1
-- WHERE   functional_class IN ('tertiary','tertiary_link')
-- AND     ft_bike_infra = 'buffered_lane'
-- AND     COALESCE(speed_limit,30) <= 30      -- we don't want to penalize for speed but if it's there it should affect stress
-- AND     COALESCE(ft_lanes,1) < 2;           -- we don't want to penalize for lanes but if it's there it should affect stress
-- UPDATE  cambridge_ways
-- SET     tf_seg_stress = 1
-- WHERE   functional_class IN ('tertiary','tertiary_link')
-- AND     tf_bike_infra = 'buffered_lane'
-- AND     COALESCE(speed_limit,30) <= 30      -- we don't want to penalize for speed but if it's there it should affect stress
-- AND     COALESCE(tf_lanes,1) < 2;           -- we don't want to penalize for lanes but if it's there it should affect stress
--
-- -- stress reduction for bike lane
-- UPDATE  cambridge_ways
-- SET     ft_seg_stress = 2
-- WHERE   functional_class IN ('tertiary','tertiary_link')
-- AND     ft_bike_infra = 'lane'
-- AND     COALESCE(speed_limit,30) <= 30      -- we don't want to penalize for speed but if it's there it should affect stress
-- AND     COALESCE(ft_lanes,1) < 2            -- we don't want to penalize for lanes but if it's there it should affect stress
-- AND     COALESCE(ft_park,0) = 0;            -- we don't want to penalize for parking but if it's there it should affect stress
-- UPDATE  cambridge_ways
-- SET     ft_seg_stress = 2
-- WHERE   functional_class IN ('tertiary','tertiary_link')
-- AND     ft_bike_infra = 'lane'
-- AND     ft_park = 1
-- AND     COALESCE(speed_limit,30) <= 30      -- we don't want to penalize for speed but if it's there it should affect stress
-- AND     COALESCE(ft_lanes,1) < 2;           -- we don't want to penalize for lanes but if it's there it should affect stress
--
-- UPDATE  cambridge_ways
-- SET     tf_seg_stress = 1
-- WHERE   functional_class IN ('tertiary','tertiary_link')
-- AND     tf_bike_infra = 'lane'
-- AND     COALESCE(tf_park,0) = 0             -- we don't want to penalize for parking but if it's there it should affect stress
-- AND     COALESCE(speed_limit,30) <= 30      -- we don't want to penalize for speed but if it's there it should affect stress
-- AND     COALESCE(tf_lanes,1) < 2;           -- we don't want to penalize for lanes but if it's there it should affect stress
