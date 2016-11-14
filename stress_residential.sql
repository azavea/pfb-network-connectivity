----------------------------------------
-- INPUTS
-- location: cambridge
-- notes: residential streets with bike lanes of any type
--        are scored as tertiary streets
----------------------------------------
UPDATE  cambridge_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class = 'residential'
AND     (ft_bike_infra IS NULL OR ft_bike_infra NOT IN ('track','buffered_lane','lane'))
AND     (tf_bike_infra IS NULL OR tf_bike_infra NOT IN ('track','buffered_lane','lane'));

-- no additional information
UPDATE  cambridge_ways
SET     ft_seg_stress = 1,
        tf_seg_stress = 1
WHERE   functional_class = 'residential'
AND     (ft_bike_infra IS NULL OR ft_bike_infra NOT IN ('track','buffered_lane','lane'))
AND     (tf_bike_infra IS NULL OR tf_bike_infra NOT IN ('track','buffered_lane','lane'));

-- stress increase for narrow one way and parking on both sides
UPDATE  cambridge_ways
SET     ft_seg_stress = 2,
        tf_seg_stress = 2
WHERE   functional_class = 'residential'
AND     (ft_bike_infra IS NULL OR ft_bike_infra NOT IN ('track','buffered_lane','lane'))
AND     (tf_bike_infra IS NULL OR tf_bike_infra NOT IN ('track','buffered_lane','lane'))
AND     width_ft <= 26
AND     ft_park = 1
AND     tf_park = 1;
