----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
UPDATE  cambridge_ways SET ft_lanes = NULL, tf_lanes = NULL, cross_lanes;

UPDATE  cambridge_ways
SET     ft_lanes =
            CASE    WHEN osm."turn:lanes:forward" IS NOT NULL
                        THEN    array_length(
                                    regexp_split_to_array(
                                        osm."turn:lanes:forward",
                                        '\|'
                                    ),
                                    1       -- only one dimension
                                )
                    WHEN osm."turn:lanes" IS NOT NULL AND one_way = 'ft'
                        THEN    array_length(
                                    regexp_split_to_array(
                                        osm."turn:lanes",
                                        '\|'
                                    ),
                                    1       -- only one dimension
                                )
                    WHEN osm."lanes:forward" IS NOT NULL
                        THEN    substring(osm."lanes:forward" FROM '\d+')::INT
                    WHEN osm."lanes" IS NOT NULL AND one_way = 'ft'
                        THEN    substring(osm."lanes" FROM '\d+')::INT
                    WHEN osm."lanes" IS NOT NULL AND one_way IS NULL
                        THEN    ceil(substring(osm."lanes" FROM '\d+')::FLOAT)
                    END,
        tf_lanes =
                    CASE    WHEN osm."turn:lanes:backward" IS NOT NULL
                                THEN    array_length(
                                            regexp_split_to_array(
                                                osm."turn:lanes:backward",
                                                '\|'
                                            ),
                                            1       -- only one dimension
                                        )
                            WHEN osm."turn:lanes" IS NOT NULL AND one_way = 'tf'
                                THEN    array_length(
                                            regexp_split_to_array(
                                                osm."turn:lanes",
                                                '\|'
                                            ),
                                            1       -- only one dimension
                                        )
                            WHEN osm."lanes:backward" IS NOT NULL
                                THEN    substring(osm."lanes:backward" FROM '\d+')::INT
                            WHEN osm."lanes" IS NOT NULL AND one_way = 'tf'
                                THEN    substring(osm."lanes" FROM '\d+')::INT
                            WHEN osm."lanes" IS NOT NULL AND one_way IS NULL
                                THEN    ceil(substring(osm."lanes" FROM '\d+')::FLOAT)
                            END,
        cross_lanes =
            CASE    WHEN osm."turn:lanes:forward" IS NOT NULL AND one_way = 'ft'
                        THEN    array_length(
                                    array_remove(
                                        regexp_split_to_array(
                                            osm."turn:lanes:forward",
                                            '\|'
                                        ),
                                        'right'     -- don't consider right-only lanes for crossing stress
                                    ),
                                    1               -- only one dimension
                                )
                    WHEN osm."turn:lanes:backward" IS NOT NULL AND one_way = 'tf'
                        THEN    array_length(
                                    array_remove(
                                        regexp_split_to_array(
                                            osm."turn:lanes:backward",
                                            '\|'
                                        ),
                                        'right'     -- don't consider right-only lanes for crossing stress
                                    ),
                                    1               -- only one dimension
                                )
                    WHEN osm."turn:lanes:forward" IS NOT NULL AND osm."turn:lanes:backward" IS NOT NULL
                        THEN    array_length(
                                    array_remove(
                                        regexp_split_to_array(
                                            osm."turn:lanes:forward",
                                            '\|'
                                        ),
                                        'right'     -- don't consider right-only lanes for crossing stress
                                    ),
                                    1               -- only one dimension
                                ) +
                                array_length(
                                    array_remove(
                                        regexp_split_to_array(
                                            osm."turn:lanes:backward",
                                            '\|'
                                        ),
                                        'right'     -- don't consider right-only lanes for crossing stress
                                    ),
                                    1               -- only one dimension
                                )
                    WHEN osm."turn:lanes" IS NOT NULL
                        THEN    array_length(
                                    array_remove(
                                        regexp_split_to_array(
                                            osm."turn:lanes",
                                            '\|'
                                        ),
                                        'right'     -- don't consider right-only lanes for crossing stress
                                    ),
                                    1               -- only one dimension
                                )
                    WHEN osm."lanes:forward" IS NOT NULL AND one_way = 'ft'
                        THEN    substring(osm."lanes:forward" FROM '\d+')::INT
                    WHEN osm."lanes:backward" IS NOT NULL AND one_way = 'tf'
                        THEN    substring(osm."lanes:backward" FROM '\d+')::INT
                    WHEN osm."lanes:forward" IS NOT NULL AND osm."lanes:backward" IS NOT NULL
                        THEN    substring(osm."lanes:forward" FROM '\d+')::INT +
                                substring(osm."lanes:backward" FROM '\d+')::INT
                    WHEN osm."lanes" IS NOT NULL
                        THEN    substring(osm."lanes" FROM '\d+')::INT
                    END

-- -- forward
-- UPDATE  cambridge_ways
-- SET     ft_lanes = substring(osm."lanes:forward" FROM '\d+')::INT
-- FROM    cambridge_osm_full_line osm
-- WHERE   cambridge_ways.osm_id = osm.osm_id
-- AND     ft_lanes IS NULL
-- AND     osm."lanes:forward" IS NOT NULL;
--
-- -- backward
-- UPDATE  cambridge_ways
-- SET     tf_lanes = substring(osm."lanes:backward" FROM '\d+')::INT
-- FROM    cambridge_osm_full_line osm
-- WHERE   cambridge_ways.osm_id = osm.osm_id
-- AND     tf_lanes IS NULL
-- AND     osm."lanes:backward" IS NOT NULL;
--
-- -- all lanes (no direction given)
-- -- two way
-- UPDATE  cambridge_ways
-- SET     ft_lanes = floor(substring(osm.lanes FROM '\d+')::FLOAT / 2),
--         tf_lanes = floor(substring(osm.lanes FROM '\d+')::FLOAT / 2)
-- FROM    cambridge_osm_full_line osm
-- WHERE   cambridge_ways.osm_id = osm.osm_id
-- AND     tf_lanes IS NULL
-- AND     ft_lanes IS NULL
-- AND     one_way_car NOT IN ('ft','tf')
-- AND     osm.lanes IS NOT NULL;
--
-- -- all lanes (no direction given)
-- -- one way
-- UPDATE  cambridge_ways
-- SET     ft_lanes = substring(osm.lanes FROM '\d+')::INT
-- FROM    cambridge_osm_full_line osm
-- WHERE   cambridge_ways.osm_id = osm.osm_id
-- AND     one_way_car = 'ft'
-- AND     ft_lanes IS NULL
-- AND     osm.lanes IS NOT NULL;
-- UPDATE  cambridge_ways
-- SET     tf_lanes = substring(osm.lanes FROM '\d+')::INT
-- FROM    cambridge_osm_full_line osm
-- WHERE   cambridge_ways.osm_id = osm.osm_id
-- AND     one_way_car = 'tf'
-- AND     tf_lanes IS NULL
-- AND     osm.lanes IS NOT NULL;
