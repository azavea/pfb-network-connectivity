-- reset opposite stress for one-way
UPDATE  neighborhood_ways
SET     ft_seg_stress = NULL
WHERE   one_way = 'tf';
UPDATE  neighborhood_ways
SET     tf_seg_stress = NULL
WHERE   one_way = 'ft';
