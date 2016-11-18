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
AND     osm.bicycle IN ('yes','permissive','designated')
AND     (osm.access IS NULL OR osm.access NOT IN ('no','private'));

UPDATE  cambridge_ways
SET     functional_class = 'living_street'
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.highway = 'pedestrian'
AND     osm.bicycle IN ('yes','permissive','designated')
AND     (osm.access IS NULL OR osm.access NOT IN ('no','private'));

-- remove stuff that we don't want to route over
DELETE FROM cambridge_ways WHERE functional_class IS NULL;

-- remove orphans
DELETE FROM cambridge_ways
WHERE   NOT EXISTS (
            SELECT  1
            FROM    cambridge_ways w
            WHERE   cambridge_ways.intersection_to IN (w.intersection_to,w.intersection_from)
            AND     w.road_id != cambridge_ways.road_id
)
AND     NOT EXISTS (
            SELECT  1
            FROM    cambridge_ways w
            WHERE   cambridge_ways.intersection_from IN (w.intersection_to,w.intersection_from)
            AND     w.road_id != cambridge_ways.road_id
);

-- remove obsolete intersections
DELETE FROM cambridge_ways_intersections
WHERE NOT EXISTS (
    SELECT  1
    FROM    cambridge_ways w
    WHERE   int_id IN (w.intersection_to,w.intersection_from)
);
