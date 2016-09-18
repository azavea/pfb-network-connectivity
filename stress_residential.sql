----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
UPDATE  cambridge_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class = 'residential';

-- no additional information
UPDATE  cambridge_ways
SET     ft_seg_stress = 1,
        tf_seg_stress = 1
WHERE   functional_class = 'residential';

-- stress increase for multiple lanes or high speeds
UPDATE  cambridge_ways
SET     ft_seg_stress = 3
WHERE   functional_class = 'residential'
AND     (ft_lanes > 1 OR speed_limit > 30);

-- stress increase for narrow one way and parking on both sides
UPDATE  cambridge_ways
SET     ft_seg_stress = 3
WHERE   functional_class = 'residential'
AND     width_ft <= 28
AND     ft_park = 1
AND     tf_park = 1;
