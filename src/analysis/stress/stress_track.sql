----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
UPDATE  neighborhood_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class = 'track';

UPDATE  neighborhood_ways
SET     ft_seg_stress = 1,
        tf_seg_stress = 1
WHERE   functional_class = 'track';
