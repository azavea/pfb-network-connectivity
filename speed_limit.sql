----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
UPDATE  cambridge_ways SET speed_limit = NULL;

UPDATE  cambridge_ways
SET     speed_limit = substring(osm.maxspeed from '\d+')::INT
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.maxspeed LIKE '% mph';
