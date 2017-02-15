----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
UPDATE neighborhood_ways_intersections SET stops = 'f';

UPDATE  neighborhood_ways_intersections
SET     stops = 't'
FROM    neighborhood_osm_full_point osm
WHERE   neighborhood_ways_intersections.osm_id = osm.osm_id
AND     osm.highway = 'stop'
AND     osm.stop = 'all';
