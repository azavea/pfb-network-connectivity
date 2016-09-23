----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
-- assume low stress, since these juncions would always be controlled or free flowing
UPDATE  cambridge_ways SET ft_int_stress = 1, tf_int_stress = 1
WHERE   functional_class 'primary';
