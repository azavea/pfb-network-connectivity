----------------------------------------
-- INPUTS
-- location: neighborhood
-- vars:
--      :sigctl_search_dist=25     Search distance for traffic signals at adjacent intersection
----------------------------------------
UPDATE neighborhood_ways_intersections SET rrfb = FALSE;

UPDATE  neighborhood_ways_intersections
SET     rrfb = TRUE
WHERE   legs > 2
AND     EXISTS (
            SELECT  1
            FROM    neighborhood_osm_full_point osm
            WHERE   osm.highway = 'crossing'
            AND     osm.flashing_lights = 'yes'
            AND     ST_DWithin(neighborhood_ways_intersections.geom, osm.way, :sigctl_search_dist)
        );
