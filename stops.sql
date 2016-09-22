----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
UPDATE cambridge_ways_intersections SET stops = 'f';

UPDATE  cambridge_ways_intersections
SET     stops = 't'
FROM    cambridge_osm_full_point osm
WHERE   cambridge_ways_intersections.osm_id = osm.osm_id
AND     osm.highway = 'stop'
AND     osm.stop = 'all';
