----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
UPDATE  cambridge_ways SET one_way = NULL;

-- ft direction
UPDATE  cambridge_ways
SET     one_way = 'ft'
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     trim(osm.oneway) IN ('1','yes');

-- tf direction
UPDATE  cambridge_ways
SET     one_way = 'tf'
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     trim(osm.oneway) = '-1';
