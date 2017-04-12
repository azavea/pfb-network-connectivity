----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
UPDATE  neighborhood_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class IN ('motorway','motorway_link','trunk','trunk_link');

UPDATE  neighborhood_ways SET ft_seg_stress = 3, tf_seg_stress = 3
WHERE   functional_class IN ('motorway','motorway_link','trunk','trunk_link');
