----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
UPDATE  neighborhood_ways SET one_way_car = NULL;

-- ft direction
UPDATE  neighborhood_ways
SET     one_way_car = 'ft'
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND     trim(osm.oneway) IN ('1','yes');

-- tf direction
UPDATE  neighborhood_ways
SET     one_way_car = 'tf'
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND     trim(osm.oneway) = '-1';
