----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
UPDATE neighborhood_ways_intersections SET signalized = 'f';

UPDATE  neighborhood_ways_intersections
SET     signalized = 't'
FROM    neighborhood_osm_full_point osm
WHERE   neighborhood_ways_intersections.osm_id = osm.osm_id
AND     osm.highway = 'traffic_signals';

UPDATE  neighborhood_ways_intersections
SET     signalized = 't'
FROM    neighborhood_ways,
        neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND     int_id = neighborhood_ways.intersection_to
AND     osm."traffic_signals:direction" = 'forward';

UPDATE  neighborhood_ways_intersections
SET     signalized = 't'
FROM    neighborhood_ways,
        neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND     int_id = neighborhood_ways.intersection_from
AND     osm."traffic_signals:direction" = 'backward';
