----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
UPDATE  received.neighborhood_ways_intersections
SET     legs = (
            SELECT  COUNT(road_id)
            FROM    neighborhood_ways
            WHERE   neighborhood_ways_intersections.int_id IN (intersection_from,intersection_to)
);
