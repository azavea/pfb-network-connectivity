----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
UPDATE cambridge_ways_intersections SET signalized = 'f';

UPDATE  cambridge_ways_intersections
SET     signalized = 't'
FROM    cambridge_osm_full_point osm
WHERE   cambridge_ways_intersections.osm_id = osm.osm_id
AND     osm.highway = 'traffic_signals';

UPDATE  cambridge_ways_intersections
SET     signalized = 't'
FROM    cambridge_ways,
        cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     int_id = cambridge_ways.intersection_to
AND     osm."traffic_signals:direction" = 'forward';

UPDATE  cambridge_ways_intersections
SET     signalized = 't'
FROM    cambridge_ways,
        cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     int_id = cambridge_ways.intersection_from
AND     osm."traffic_signals:direction" = 'backward';
