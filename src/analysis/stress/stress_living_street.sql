----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
UPDATE  neighborhood_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class = 'living_street';

UPDATE  neighborhood_ways
SET     ft_seg_stress = 3,
        tf_seg_stress = 3
FROM    neighborhood_osm_full_line osm
WHERE   functional_class = 'living_street'
AND     neighborhood_ways.osm_id = osm.osm_id
AND     osm.bicycle = 'no';

UPDATE  neighborhood_ways
SET     ft_seg_stress = COALESCE(ft_seg_stress,1),
        tf_seg_stress = COALESCE(tf_seg_stress,1)
WHERE   functional_class = 'living_street';
