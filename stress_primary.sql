----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
UPDATE  cambridge_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class IN ('primary','primary_link');

-- no additional information
UPDATE  cambridge_ways
SET     ft_seg_stress = 4,
        tf_seg_stress = 4
WHERE   functional_class IN ('primary','primary_link');

-- stress reduction for cycle track
UPDATE  cambridge_ways
SET     ft_seg_stress = 2
WHERE   functional_class IN ('primary','primary_link')
AND     ft_bike_infra = 'track';
UPDATE  cambridge_ways
SET     tf_seg_stress = 2
WHERE   functional_class IN ('primary','primary_link')
AND     tf_bike_infra = 'track';
