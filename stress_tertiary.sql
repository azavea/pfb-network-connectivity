----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
UPDATE  cambridge_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class IN ('tertiary','tertiary_link');

-- no additional information
UPDATE  cambridge_ways
SET     ft_seg_stress = 3,
        tf_seg_stress = 3
WHERE   functional_class IN ('tertiary','tertiary_link');

-- stress reduction for cycle track
UPDATE  cambridge_ways
SET     ft_seg_stress = 2
WHERE   functional_class IN ('tertiary','tertiary_link')
AND     ft_bike_infra = 'track';
UPDATE  cambridge_ways
SET     tf_seg_stress = 2
WHERE   functional_class IN ('tertiary','tertiary_link')
AND     tf_bike_infra = 'track';

-- stress reduction for buffered lane
UPDATE  cambridge_ways
SET     ft_seg_stress = 2
WHERE   functional_class IN ('tertiary','tertiary_link')
AND     ft_bike_infra = 'buffered_lane'
AND     COALESCE(speed_limit,30) <= 30      -- we don't want to penalize for speed but if it's there it should affect stress
AND     COALESCE(ft_lanes,1) < 2;           -- we don't want to penalize for lanes but if it's there it should affect stress
UPDATE  cambridge_ways
SET     tf_seg_stress = 2
WHERE   functional_class IN ('tertiary','tertiary_link')
AND     tf_bike_infra = 'buffered_lane'
AND     COALESCE(speed_limit,30) <= 30      -- we don't want to penalize for speed but if it's there it should affect stress
AND     COALESCE(tf_lanes,1) < 2;           -- we don't want to penalize for lanes but if it's there it should affect stress

-- stress reduction for bike lane
UPDATE  cambridge_ways
SET     ft_seg_stress = 2
WHERE   functional_class IN ('tertiary','tertiary_link')
AND     ft_bike_infra = 'lane'
AND     COALESCE(ft_park,0) = 0             -- we don't want to penalize for parking but if it's there it should affect stress
AND     COALESCE(speed_limit,30) <= 30      -- we don't want to penalize for speed but if it's there it should affect stress
AND     COALESCE(ft_lanes,1) < 2;           -- we don't want to penalize for lanes but if it's there it should affect stress
UPDATE  cambridge_ways
SET     tf_seg_stress = 2
WHERE   functional_class IN ('tertiary','tertiary_link')
AND     tf_bike_infra = 'lane'
AND     COALESCE(tf_park,0) = 0             -- we don't want to penalize for parking but if it's there it should affect stress
AND     COALESCE(speed_limit,30) <= 30      -- we don't want to penalize for speed but if it's there it should affect stress
AND     COALESCE(tf_lanes,1) < 2;           -- we don't want to penalize for lanes but if it's there it should affect stress
