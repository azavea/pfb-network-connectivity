----------------------------------------
-- INPUTS
-- location: neighborhood
-- vars:
--      :sigctl_search_dist=25     Search distance for traffic signals at adjacent intersection
----------------------------------------
UPDATE neighborhood_ways_intersections SET signalized = 'f';

-----------------------------------
-- traffic signals
-----------------------------------
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


-----------------------------------
-- HAWKs and other variants
-----------------------------------
UPDATE  neighborhood_ways_intersections
SET     signalized = 't'
WHERE   legs > 2
AND     EXISTS (
            SELECT  1
            FROM    neighborhood_osm_full_point osm
            WHERE   osm.highway = 'crossing'
            AND     osm.crossing IN ('traffic_signals','pelican','toucan')
            AND     ST_DWithin(neighborhood_ways_intersections.geom, osm.way, :sigctl_search_dist)
        );


-----------------------------------
-- Capture signals from other points
-- on the intersection
-----------------------------------
UPDATE  neighborhood_ways_intersections
SET     signalized = 't'
WHERE   legs > 2
AND     EXISTS (
            SELECT  1
            FROM    neighborhood_ways_intersections i
            WHERE   i.signalized
            AND     ST_DWithin(neighborhood_ways_intersections.geom, i.geom, :sigctl_search_dist)
        );
