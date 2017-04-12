----------------------------------------
-- INPUTS
-- location: neighborhood
-- vars:
--      :sigctl_search_dist=25     Search distance for traffic signals at adjacent intersection
----------------------------------------
UPDATE neighborhood_ways_intersections SET stops = 'f';

UPDATE  neighborhood_ways_intersections
SET     stops = 't'
FROM    neighborhood_osm_full_point osm
WHERE   neighborhood_ways_intersections.osm_id = osm.osm_id
AND     osm.highway = 'stop'
AND     osm.stop = 'all';

UPDATE  neighborhood_ways_intersections
SET     stops = 't'
WHERE   legs > 2
AND     EXISTS (
            SELECT  1
            FROM    neighborhood_ways_intersections i
            WHERE   i.stops
            AND     ST_DWithin(neighborhood_ways_intersections.geom, i.geom, :sigctl_search_dist)
        );
