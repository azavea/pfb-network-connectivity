----------------------------------------
-- INPUTS
-- location: neighborhood
-- notes: residential streets with bike lanes of any type
--        are scored as tertiary streets
----------------------------------------
UPDATE  neighborhood_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class = 'residential'
AND     (ft_bike_infra IS NULL OR ft_bike_infra NOT IN ('track','buffered_lane','lane'))
AND     (tf_bike_infra IS NULL OR tf_bike_infra NOT IN ('track','buffered_lane','lane'))
AND     (ft_lanes IS NULL OR ft_lanes = 1)
AND     (ft_lanes IS NULL OR tf_lanes = 1)
AND     (speed_limit IS NULL OR speed_limit <= 30);


-- no additional information
UPDATE  neighborhood_ways
SET     ft_seg_stress = 1,
        tf_seg_stress = 1
WHERE   functional_class = 'residential'
AND     (ft_bike_infra IS NULL OR ft_bike_infra NOT IN ('track','buffered_lane','lane'))
AND     (tf_bike_infra IS NULL OR tf_bike_infra NOT IN ('track','buffered_lane','lane'))
AND     (ft_lanes IS NULL OR ft_lanes = 1)
AND     (ft_lanes IS NULL OR tf_lanes = 1)
AND     (speed_limit IS NULL OR speed_limit <= 30);

-- stress increase for narrow one way and parking on both sides
UPDATE  neighborhood_ways
SET     ft_seg_stress = 2,
        tf_seg_stress = 2
WHERE   functional_class = 'residential'
AND     (ft_bike_infra IS NULL OR ft_bike_infra NOT IN ('track','buffered_lane','lane'))
AND     (tf_bike_infra IS NULL OR tf_bike_infra NOT IN ('track','buffered_lane','lane'))
AND     (ft_lanes IS NULL OR ft_lanes = 1)
AND     (ft_lanes IS NULL OR tf_lanes = 1)
AND     (speed_limit IS NULL OR speed_limit <= 30)
AND     width_ft <= 26
AND     ft_park = 1
AND     tf_park = 1;
