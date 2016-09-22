----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
UPDATE  cambridge_ways SET functional_class = NULL;

UPDATE  cambridge_ways
SET     functional_class = osm.highway
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.highway IN (
            'motorway',
            'tertiary',
            'trunk',
            'tertiary_link',
            'motorway_link',
            'secondary_link',
            'primary_link',
            'trunk_link',
            'residential',
            'secondary',
            'primary',
            'living_street'
);                          -- note that we're leaving out "road"

UPDATE  cambridge_ways
SET     functional_class = 'tertiary'
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.highway = 'unclassified';

UPDATE  cambridge_ways
SET     functional_class = 'track'
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.highway = 'track'
AND     osm.tracktype = 'grade1';

UPDATE  cambridge_ways
SET     functional_class = 'path'
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.highway IN ('cycleway','path');

UPDATE  cambridge_ways
SET     functional_class = 'path'
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.highway = 'footway'
AND     osm.bicycle IN ('yes','permissive')
AND     (osm.access IS NULL OR osm.access NOT IN ('no','private'));

UPDATE  cambridge_ways
SET     functional_class = 'living_street'
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.highway = 'pedestrian'
AND     osm.bicycle IN ('yes','permissive')
AND     (osm.access IS NULL OR osm.access NOT IN ('no','private'));

DELETE FROM cambridge_ways WHERE functional_class IS NULL;
DELETE FROM cambridge_ways_intersections
WHERE NOT EXISTS (
    SELECT  1
    FROM    cambridge_ways
    WHERE   cambridge_ways_intersections.int_id IN (intersection_from,intersection_to)
);
--elevators?
