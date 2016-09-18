----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
UPDATE  cambridge_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class IN ('secondary','secondary_link');

-- no additional information
UPDATE  cambridge_ways
SET     ft_seg_stress = 4,
        tf_seg_stress = 4
WHERE   functional_class IN ('secondary','secondary_link');

-- stress reduction for cycle track
UPDATE  cambridge_ways
SET     ft_seg_stress = 2
WHERE   functional_class IN ('secondary','secondary_link')
AND     ft_bike_infra = 'track';
UPDATE  cambridge_ways
SET     tf_seg_stress = 2
WHERE   functional_class IN ('secondary','secondary_link')
AND     tf_bike_infra = 'track';

-- stress reduction for one vehicle lane and buffered lane
UPDATE  cambridge_ways
SET     ft_seg_stress = 2
WHERE   functional_class IN ('secondary','secondary_link')
AND     ft_bike_infra = 'buffered_lane'
AND     ft_lanes = 1
AND     speed_limit <= 30;
UPDATE  cambridge_ways
SET     tf_seg_stress = 2
WHERE   functional_class IN ('secondary','secondary_link')
AND     tf_bike_infra = 'buffered_lane'
AND     tf_lanes = 1
AND     speed_limit <= 30;

-- stress reduction for one vehicle lane, no parking, and bike lane
UPDATE  cambridge_ways
SET     ft_seg_stress = 2
WHERE   functional_class IN ('secondary','secondary_link')
AND     ft_bike_infra = 'lane'
AND     ft_lanes = 1
AND     ft_park = 0
AND     speed_limit <= 30;
UPDATE  cambridge_ways
SET     tf_seg_stress = 2
WHERE   functional_class IN ('secondary','secondary_link')
AND     tf_bike_infra = 'lane'
AND     tf_lanes = 1
AND     ft_park = 0
AND     speed_limit <= 30;
