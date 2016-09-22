----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
-- start with assuming that every intersection is stressful
UPDATE  cambridge_ways SET ft_int_stress = 3, tf_int_stress = 3;

-- primary and higher
-- assume low stress, since these juncions would always be controlled
UPDATE  cambridge_ways SET ft_int_stress = 1, tf_int_stress = 1
WHERE   functional_class IN ('motorway','motorway_link','trunk','trunk_link','primary','primary_link');








-- secondary
-- assume low stress unless the junction is with primary or higher
UPDATE  cambridge_ways SET ft_int_stress = 1
WHERE   functional_class IN ('secondary','secondary_link')
AND     NOT EXISTS (
            SELECT  1
            FROM    cambridge_ways w
            WHERE   intersection_to IN (w.intersection_to,w.intersection_from)
            AND     COALESCE(cambridge_ways.name,'a') != COALESCE(w.name,'b')
            AND     w.functional_class IN (
                        'motorway','motorway_link',
                        'trunk','trunk_link',
                        'primary','primary_link'
                        'secondary','secondary_link'
            )
);
UPDATE  cambridge_ways SET tf_int_stress = 1
WHERE   functional_class IN ('secondary','secondary_link')
AND     NOT EXISTS (
            SELECT  1
            FROM    cambridge_ways w
            WHERE   intersection_from IN (w.intersection_to,w.intersection_from)
            AND     COALESCE(cambridge_ways.name,'a') != COALESCE(w.name,'b')
            AND     w.functional_class IN (
                        'motorway','motorway_link',
                        'trunk','trunk_link',
                        'primary','primary_link'
                        'secondary','secondary_link'
            )
);

-- secondary
-- assume low stress unless the junction is with secondary or higher
UPDATE  cambridge_ways SET ft_int_stress = 1
WHERE   functional_class IN ('secondary','secondary_link')
AND     NOT EXISTS (
            SELECT  1
            FROM    cambridge_ways w
            WHERE   intersection_to IN (w.intersection_to,w.intersection_from)
            AND     COALESCE(cambridge_ways.name,'a') != COALESCE(w.name,'b')
            AND     w.functional_class IN (
                        'motorway','motorway_link',
                        'trunk','trunk_link',
                        'primary','primary_link'
                        'secondary','secondary_link'
            )
);
UPDATE  cambridge_ways SET tf_int_stress = 1
WHERE   functional_class IN ('secondary','secondary_link')
AND     NOT EXISTS (
            SELECT  1
            FROM    cambridge_ways w
            WHERE   intersection_from IN (w.intersection_to,w.intersection_from)
            AND     COALESCE(cambridge_ways.name,'a') != COALESCE(w.name,'b')
            AND     w.functional_class IN (
                        'motorway','motorway_link',
                        'trunk','trunk_link',
                        'primary','primary_link'
                        'secondary','secondary_link'
            )
);
-- assign low stress if lane and speed data are present and meet requirements
UPDATE  cambridge_ways SET ft_int_stress = 1
WHERE   functional_class IN ('secondary','secondary_link')
AND     EXISTS (
            SELECT  1
            FROM    cambridge_ways w
            WHERE   intersection_to IN (w.intersection_to,w.intersection_from)
            AND     COALESCE(cambridge_ways.name,'a') != COALESCE(w.name,'b')
            AND     w.functional_class IN (
                        'motorway','motorway_link',
                        'trunk','trunk_link',
                        'primary','primary_link'
                        'secondary','secondary_link'
            )
);




-- residential and lower
UPDATE  cambridge_ways
SET     ft_int_stress = CASE
                        WHEN
                                THEN
WHERE functional_class IN ('residential','living_street','track','path')



-- UPDATE  cambridge_ways
-- SET     ft_int_stress = (
--             SELECT  MAX(GREATEST(r.ft_seg_stress,r.tf_seg_stress))
--             FROM    cambridge_ways r
--             WHERE   NOT r.road_id = cambridge_ways.road_id
--             AND     cambridge_ways.intersection_to IN (r.intersection_from,r.intersection_to)
-- );
-- UPDATE  generated.roads
-- SET     tf_int_stress = (
--             SELECT  MAX(GREATEST(r.ft_seg_stress,r.tf_seg_stress))
--             FROM    cambridge_ways r
--             WHERE   NOT r.road_id = cambridge_ways.road_id
--             AND     cambridge_ways.intersection_from IN (r.intersection_from,r.intersection_to)
-- );



-- reduce stress for non-intersections
UPDATE  cambridge_ways
SET     ft_int_stress = 1
FROM    cambridge_ways_intersections i
WHERE   cambridge_ways.intersection_to = i.int_id
AND     i.legs < 3;
UPDATE  cambridge_ways
SET     tf_int_stress = 1
FROM    cambridge_ways_intersections i
WHERE   cambridge_ways.intersection_from = i.int_id
AND     i.legs < 3;

-- reduce stress for stoplights or all-way stops
UPDATE  cambridge_ways
SET     ft_int_stress = 1
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_ways_intersections i
            WHERE   i.int_id = cambridge_ways.intersection_to
            AND     (i.signalized OR i.stops)
);
UPDATE  cambridge_ways
SET     tf_int_stress = 1
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_ways_intersections i
            WHERE   i.int_id = cambridge_ways.intersection_from
            AND     (i.signalized OR i.stops)
);
