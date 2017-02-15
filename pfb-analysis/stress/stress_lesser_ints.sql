----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
UPDATE  neighborhood_ways SET ft_int_stress = 1, tf_int_stress = 1
WHERE   functional_class IN ('residential','living_street','track','path');

-- ft
UPDATE  neighborhood_ways
SET     ft_int_stress = 3
WHERE   functional_class IN ('residential','living_street','track','path')
AND     EXISTS (
            SELECT  1
            FROM    neighborhood_ways w
            WHERE   neighborhood_ways.intersection_to IN (w.intersection_to,w.intersection_from)
            AND     COALESCE(neighborhood_ways.name,'a') != COALESCE(w.name,'b')
            AND     CASE
                    WHEN w.functional_class IN ('motorway','trunk','primary')
                        THEN    CASE
                                WHEN w.ft_lanes + w.tf_lanes < 4
                                    THEN    CASE
                                            WHEN w.speed_limit <= 30 THEN 0::BOOLEAN
                                            ELSE 1::BOOLEAN
                                            END
                                WHEN w.ft_lanes + w.tf_lanes = 4
                                    THEN    CASE
                                            WHEN w.speed_limit <= 25 THEN 0::BOOLEAN
                                            ELSE 1::BOOLEAN
                                            END
                                ELSE 1::BOOLEAN
                                END
                    WHEN w.functional_class = 'secondary'
                        THEN    CASE
                                WHEN w.ft_lanes + w.tf_lanes >= 5
                                    THEN 1::BOOLEAN
                                WHEN w.ft_lanes + w.tf_lanes < 4
                                    THEN    CASE
                                            WHEN w.speed_limit > 30 THEN 1::BOOLEAN
                                            ELSE 0::BOOLEAN
                                            END
                                ELSE    CASE
                                        WHEN w.speed_limit <= 25 THEN 0::BOOLEAN
                                        ELSE 1::BOOLEAN
                                        END
                                END
                    WHEN w.functional_class = 'tertiary'
                        THEN    CASE
                                WHEN w.ft_lanes + w.tf_lanes >= 5
                                    THEN 1::BOOLEAN
                                WHEN w.ft_lanes + w.tf_lanes = 4
                                    THEN    CASE
                                            WHEN w.speed_limit > 25 THEN 1::BOOLEAN
                                            ELSE 0::BOOLEAN
                                            END
                                ELSE    CASE
                                        WHEN w.speed_limit > 30 THEN 1::BOOLEAN
                                        ELSE 0::BOOLEAN
                                        END
                                END
                    ELSE 0::BOOLEAN
                    END
);

-- tf
UPDATE  neighborhood_ways
SET     tf_int_stress = 3
WHERE   functional_class IN ('residential','living_street','track','path')
AND     EXISTS (
            SELECT  1
            FROM    neighborhood_ways w
            WHERE   neighborhood_ways.intersection_from IN (w.intersection_to,w.intersection_from)
            AND     COALESCE(neighborhood_ways.name,'a') != COALESCE(w.name,'b')
            AND     CASE
                    WHEN w.functional_class IN ('motorway','trunk','primary')
                        THEN    CASE
                                WHEN w.ft_lanes + w.tf_lanes < 4
                                    THEN    CASE
                                            WHEN w.speed_limit <= 30 THEN 0::BOOLEAN
                                            ELSE 1::BOOLEAN
                                            END
                                WHEN w.ft_lanes + w.tf_lanes = 4
                                    THEN    CASE
                                            WHEN w.speed_limit <= 25 THEN 0::BOOLEAN
                                            ELSE 1::BOOLEAN
                                            END
                                ELSE 1::BOOLEAN
                                END
                    WHEN w.functional_class = 'secondary'
                        THEN    CASE
                                WHEN w.ft_lanes + w.tf_lanes >= 5
                                    THEN 1::BOOLEAN
                                WHEN w.ft_lanes + w.tf_lanes < 4
                                    THEN    CASE
                                            WHEN w.speed_limit > 30 THEN 1::BOOLEAN
                                            ELSE 0::BOOLEAN
                                            END
                                ELSE    CASE
                                        WHEN w.speed_limit <= 25 THEN 0::BOOLEAN
                                        ELSE 1::BOOLEAN
                                        END
                                END
                    WHEN w.functional_class = 'tertiary'
                        THEN    CASE
                                WHEN w.ft_lanes + w.tf_lanes >= 5
                                    THEN 1::BOOLEAN
                                WHEN w.ft_lanes + w.tf_lanes = 4
                                    THEN    CASE
                                            WHEN w.speed_limit > 25 THEN 1::BOOLEAN
                                            ELSE 0::BOOLEAN
                                            END
                                ELSE    CASE
                                        WHEN w.speed_limit > 30 THEN 1::BOOLEAN
                                        ELSE 0::BOOLEAN
                                        END
                                END
                    ELSE 0::BOOLEAN
                    END
);
