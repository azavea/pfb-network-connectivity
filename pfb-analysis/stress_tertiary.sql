----------------------------------------
-- INPUTS
-- location: neighborhood
-- notes: this includes residential streets that have bike lanes
--        of any type
----------------------------------------
UPDATE  neighborhood_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class IN ('tertiary','tertiary_link')
OR      (functional_class = 'residential' AND ft_bike_infra IN ('track','buffered_lane','lane'))
OR      (functional_class = 'residential' AND tf_bike_infra IN ('track','buffered_lane','lane'))
OR      (functional_class = 'residential' AND ft_lanes > 1)
OR      (functional_class = 'residential' AND tf_lanes > 1)
OR      (functional_class = 'residential' AND speed_limit > 30);

-- ft direction
UPDATE  neighborhood_ways
SET     ft_seg_stress =
            CASE
            WHEN ft_bike_infra = 'track' THEN 1
            WHEN ft_bike_infra = 'buffered_lane'
                    THEN    CASE
                            WHEN speed_limit = 35
                                    THEN    CASE
                                            WHEN ft_lanes > 1 THEN 3
                                            ELSE 2  -- assume 1 lane
                                            END
                            WHEN speed_limit > 35
                                    THEN    CASE
                                            WHEN ft_lanes > 1 THEN 3
                                            ELSE 2  -- assume 1 lane
                                            END
                            ELSE    CASE                        -- assume speed 30
                                    WHEN ft_lanes > 1 THEN 2
                                    ELSE 1      -- assume 1 lane
                                    END
                            END
            WHEN ft_bike_infra = 'lane'
                    THEN    CASE
                            WHEN speed_limit > 30 THEN 3
                            WHEN speed_limit <= 20
                                    THEN    CASE
                                            WHEN ft_lanes > 2 THEN 3
                                            WHEN ft_lanes = 2
                                                    THEN    CASE
                                                            WHEN ft_park = 0 THEN 2
                                                            ELSE 2  -- assume parking
                                                            END
                                            ELSE    CASE    -- assume 1 lane
                                                    WHEN ft_park = 0 THEN 1
                                                    ELSE 2  -- assume parking
                                                    END
                                            END
                            WHEN speed_limit = 25
                                    THEN    CASE
                                            WHEN ft_lanes > 2 THEN 3
                                            WHEN ft_lanes = 2
                                                    THEN    CASE
                                                            WHEN ft_park = 0 THEN 2
                                                            ELSE 3  -- assume parking
                                                            END
                                            ELSE    CASE    -- assume 1 lane
                                                    WHEN ft_park = 0 THEN 1
                                                    ELSE 2  -- assume parking
                                                    END
                                            END
                            ELSE    CASE    -- assume 30 mph speed limit
                                    WHEN ft_lanes > 1 THEN 3
                                    ELSE    CASE    -- assume 1 lane
                                            WHEN ft_park = 0 THEN 1
                                            ELSE 2  -- assume parking
                                            END
                                    END
                            END
            ELSE    CASE
                    WHEN speed_limit = 30
                            THEN    CASE
                                    WHEN ft_lanes = 1 THEN 2
                                    ELSE 3  -- assumee more than 1 lane
                                    END
                    WHEN speed_limit <= 25
                            THEN    CASE
                                    WHEN ft_lanes = 1 THEN 1
                                    ELSE 3  -- assumee more than 1 lane
                                    END
                    ELSE 3
                    END
            END
WHERE   functional_class IN ('tertiary','tertiary_link')
OR      (functional_class = 'residential' AND ft_bike_infra IN ('track','buffered_lane','lane'))
OR      (functional_class = 'residential' AND tf_bike_infra IN ('track','buffered_lane','lane'))
OR      (functional_class = 'residential' AND ft_lanes > 1)
OR      (functional_class = 'residential' AND tf_lanes > 1)
OR      (functional_class = 'residential' AND speed_limit > 30);

-- tf direction
UPDATE  neighborhood_ways
SET     tf_seg_stress =
            CASE
            WHEN tf_bike_infra = 'track' THEN 1
            WHEN tf_bike_infra = 'buffered_lane'
                    THEN    CASE
                            WHEN speed_limit = 35
                                    THEN    CASE
                                            WHEN tf_lanes > 1 THEN 3
                                            ELSE 2  -- assume 1 lane
                                            END
                            WHEN speed_limit > 35
                                    THEN    CASE
                                            WHEN tf_lanes > 1 THEN 3
                                            ELSE 2  -- assume 1 lane
                                            END
                            ELSE    CASE                        -- assume speed 30
                                    WHEN tf_lanes > 1 THEN 2
                                    ELSE 1      -- assume 1 lane
                                    END
                            END
            WHEN tf_bike_infra = 'lane'
                    THEN    CASE
                            WHEN speed_limit > 30 THEN 3
                            WHEN speed_limit <= 20
                                    THEN    CASE
                                            WHEN tf_lanes > 2 THEN 3
                                            WHEN tf_lanes = 2
                                                    THEN    CASE
                                                            WHEN tf_park = 0 THEN 2
                                                            ELSE 2  -- assume parking
                                                            END
                                            ELSE    CASE    -- assume 1 lane
                                                    WHEN tf_park = 0 THEN 1
                                                    ELSE 2  -- assume parking
                                                    END
                                            END
                            WHEN speed_limit = 25
                                    THEN    CASE
                                            WHEN tf_lanes > 2 THEN 3
                                            WHEN tf_lanes = 2
                                                    THEN    CASE
                                                            WHEN tf_park = 0 THEN 2
                                                            ELSE 3  -- assume parking
                                                            END
                                            ELSE    CASE    -- assume 1 lane
                                                    WHEN tf_park = 0 THEN 1
                                                    ELSE 2  -- assume parking
                                                    END
                                            END
                            ELSE    CASE    -- assume 30 mph speed limit
                                    WHEN tf_lanes > 1 THEN 3
                                    ELSE    CASE    -- assume 1 lane
                                            WHEN tf_park = 0 THEN 1
                                            ELSE 2  -- assume parking
                                            END
                                    END
                            END
            ELSE    CASE
                    WHEN speed_limit = 30
                            THEN    CASE
                                    WHEN tf_lanes = 1 THEN 2
                                    ELSE 3  -- assumee more than 1 lane
                                    END
                    WHEN speed_limit <= 25
                            THEN    CASE
                                    WHEN tf_lanes = 1 THEN 1
                                    ELSE 3  -- assumee more than 1 lane
                                    END
                    ELSE 3
                    END
            END
WHERE   functional_class IN ('tertiary','tertiary_link')
OR      (functional_class = 'residential' AND ft_bike_infra IN ('track','buffered_lane','lane'))
OR      (functional_class = 'residential' AND tf_bike_infra IN ('track','buffered_lane','lane'))
OR      (functional_class = 'residential' AND ft_lanes > 1)
OR      (functional_class = 'residential' AND tf_lanes > 1)
OR      (functional_class = 'residential' AND speed_limit > 30);
