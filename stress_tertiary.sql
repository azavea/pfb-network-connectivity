----------------------------------------
-- INPUTS
-- location: cambridge
-- notes: this includes residential streets that have bike lanes
--        of any type
----------------------------------------
UPDATE  cambridge_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class IN ('tertiary','tertiary_link')
OR      (functional_class = 'residential' AND ft_bike_infra IN ('track','buffered_lane','lane'))
OR      (functional_class = 'residential' AND tf_bike_infra IN ('track','buffered_lane','lane'));

-- ft direction
UPDATE  cambridge_ways
SET     ft_seg_stress =
            CASE
            WHEN ft_bike_infra = 'track' THEN 1
            WHEN ft_bike_infra = 'buffered_lane'
                    THEN    CASE
                            WHEN speed_limit > 35 THEN  3
                            WHEN speed_limit = 35 THEN  CASE
                                                        WHEN ft_lanes = 1 THEN 2
                                                        ELSE 3
                                                        END
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
                                                                    WHEN ft_park = 1 THEN 2
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
WHERE   functional_class IN ('tertiary','tertiary_link')
OR      (functional_class = 'residential' AND ft_bike_infra IN ('track','buffered_lane','lane'))
OR      (functional_class = 'residential' AND tf_bike_infra IN ('track','buffered_lane','lane'));

-- tf direction
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
                                                                    WHEN tf_park = 1 THEN 2
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
WHERE   functional_class IN ('tertiary','tertiary_link')
OR      (functional_class = 'residential' AND ft_bike_infra IN ('track','buffered_lane','lane'))
OR      (functional_class = 'residential' AND tf_bike_infra IN ('track','buffered_lane','lane'));
