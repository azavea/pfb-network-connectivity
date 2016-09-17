----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
UPDATE  cambridge_ways SET one_way_car = NULL;

-- ft direction
UPDATE  cambridge_ways
SET     one_way_car = 'ft'
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     trim(osm.oneway) IN ('1','yes');

-- tf direction
UPDATE  cambridge_ways
SET     one_way_car = 'tf'
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     trim(osm.oneway) = '-1';
