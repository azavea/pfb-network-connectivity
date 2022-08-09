----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
UPDATE  neighborhood_ways SET speed_limit = NULL;

-- convert kmph to mph and round to nearest 5
UPDATE  neighborhood_ways
SET     speed_limit = ROUND(substring(osm.maxspeed from '\d+')::INT / 1.609 / 5)*5
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND     (osm.maxspeed LIKE '% kmph' OR osm.maxspeed ~ '^\d+(\.\d+)?$');

UPDATE  neighborhood_ways
SET     speed_limit = substring(osm.maxspeed from '\d+')::INT
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND     osm.maxspeed LIKE '% mph';
