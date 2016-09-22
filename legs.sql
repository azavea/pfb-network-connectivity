----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
UPDATE  received.cambridge_ways_intersections
SET     legs = (
            SELECT  COUNT(road_id)
            FROM    cambridge_ways
            WHERE   cambridge_ways_intersections.int_id IN (intersection_from,intersection_to)
);
