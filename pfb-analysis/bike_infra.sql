----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
UPDATE  neighborhood_ways SET ft_bike_infra = NULL, tf_bike_infra = NULL;

----------------------
-- ft direction
----------------------
-- sharrow
UPDATE  neighborhood_ways
SET     ft_bike_infra = 'sharrow'
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND (
            osm."cycleway:both" = 'shared_lane'
        OR  (COALESCE(one_way_car,'ft') = 'ft' AND osm.cycleway = 'shared_lane')
        OR  (COALESCE(one_way_car,'ft') = 'ft' AND osm."cycleway:right" = 'shared_lane')
        OR  (one_way_car = 'ft' AND osm."cycleway:left" = 'shared_lane')
);

-- lane
UPDATE  neighborhood_ways
SET     ft_bike_infra = 'lane'
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND (
            osm."cycleway:both" = 'lane'
        OR  (COALESCE(one_way_car,'ft') = 'ft' AND osm.cycleway = 'lane')
        OR  (COALESCE(one_way_car,'ft') = 'ft' AND osm."cycleway:right" = 'lane')
        OR  (one_way_car = 'ft' AND osm."cycleway:left" = 'lane')
        OR  (one_way_car = 'tf' AND osm.cycleway = 'opposite_lane')
        OR  (one_way_car = 'tf' AND osm."cycleway:left" = 'opposite_lane')
);

-- buffered lane
UPDATE  neighborhood_ways
SET     ft_bike_infra = 'buffered_lane'
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND (
            osm."cycleway:both" = 'buffered_lane'
        OR  (COALESCE(one_way_car,'ft') = 'ft' AND osm.cycleway = 'buffered_lane')
        OR  (COALESCE(one_way_car,'ft') = 'ft' AND osm."cycleway:right" = 'buffered_lane')
        OR  (COALESCE(one_way_car,'ft') = 'ft' AND osm.cycleway = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left'))
        OR  (COALESCE(one_way_car,'ft') = 'ft' AND osm."cycleway:right" = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left'))
        OR  (COALESCE(one_way_car,'ft') = 'ft' AND osm."cycleway:right" = 'lane' AND osm."cycleway:right:buffer" IN ('yes','both','right','left'))
        OR  (one_way_car = 'ft' AND osm."cycleway:left" = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left'))
        OR  (one_way_car = 'ft' AND osm."cycleway:left" = 'lane' AND osm."cycleway:left:buffer" IN ('yes','both','right','left'))
        OR  (one_way_car = 'tf' AND osm.cycleway = 'opposite_lane' AND osm."cycleway:buffer" IN ('yes','both','right','left'))
        OR  (one_way_car = 'tf' AND osm."cycleway:left" = 'opposite_lane' AND osm."cycleway:buffer" IN ('yes','both','right','left'))
        OR  (one_way_car = 'tf' AND osm."cycleway:left" = 'opposite_lane' AND osm."cycleway:left:buffer" IN ('yes','both','right','left'))
);

-- track
UPDATE  neighborhood_ways
SET     ft_bike_infra = 'track'
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND (
            osm."cycleway:both" = 'track'
        OR  (osm."cycleway:right" = 'track' AND osm."oneway:bicycle" = 'no')
        OR  (osm."cycleway:left" = 'track' AND osm."oneway:bicycle" = 'no')
        OR  (osm.cycleway = 'track' AND osm."oneway:bicycle" = 'no')
        OR  (COALESCE(one_way_car,'ft') = 'ft' AND osm."cycleway" = 'track')
        OR  (COALESCE(one_way_car,'ft') = 'ft' AND osm."cycleway:right" = 'track')
        OR  (one_way_car = 'tf' AND osm."cycleway" = 'opposite_track')
        OR  (one_way_car = 'tf' AND osm."cycleway:left" = 'opposite_track')
        OR  (one_way_car = 'tf' AND osm."cycleway:right" = 'opposite_track')
);


----------------------
-- tf direction
----------------------
-- sharrow
UPDATE  neighborhood_ways
SET     tf_bike_infra = 'sharrow'
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND (
            osm."cycleway:both" = 'shared_lane'
        OR  (COALESCE(one_way_car,'tf') = 'tf' AND osm.cycleway = 'shared_lane')
        OR  (COALESCE(one_way_car,'tf') = 'tf' AND osm."cycleway:left" = 'shared_lane')
        OR  (one_way_car = 'tf' AND osm."cycleway:right" = 'shared_lane')
);

-- lane
UPDATE  neighborhood_ways
SET     tf_bike_infra = 'lane'
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND (
            osm."cycleway:both" = 'lane'
        OR  (COALESCE(one_way_car,'tf') = 'tf' AND osm.cycleway = 'lane')
        OR  (COALESCE(one_way_car,'tf') = 'tf' AND osm."cycleway:left" = 'lane')
        OR  (one_way_car = 'tf' AND osm."cycleway:right" = 'lane')
        OR  (one_way_car = 'ft' AND osm.cycleway = 'opposite_lane')
        OR  (one_way_car = 'ft' AND osm."cycleway:right" = 'opposite_lane')
);

-- buffered lane
UPDATE  neighborhood_ways
SET     tf_bike_infra = 'buffered_lane'
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND (
            osm."cycleway:both" = 'buffered_lane'
        OR  (COALESCE(one_way_car,'tf') = 'tf' AND osm.cycleway = 'buffered_lane')
        OR  (COALESCE(one_way_car,'tf') = 'tf' AND osm."cycleway:left" = 'buffered_lane')
        OR  (COALESCE(one_way_car,'tf') = 'tf' AND osm.cycleway = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left'))
        OR  (COALESCE(one_way_car,'tf') = 'tf' AND osm."cycleway:left" = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left'))
        OR  (COALESCE(one_way_car,'tf') = 'tf' AND osm."cycleway:left" = 'lane' AND osm."cycleway:left:buffer" IN ('yes','both','right','left'))
        OR  (one_way_car = 'tf' AND osm."cycleway:right" = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left'))
        OR  (one_way_car = 'tf' AND osm."cycleway:right" = 'lane' AND osm."cycleway:right:buffer" IN ('yes','both','right','left'))
        OR  (one_way_car = 'ft' AND osm.cycleway = 'opposite_lane' AND osm."cycleway:buffer" IN ('yes','both','right','left'))
        OR  (one_way_car = 'ft' AND osm."cycleway:right" = 'opposite_lane' AND osm."cycleway:buffer" IN ('yes','both','right','left'))
        OR  (one_way_car = 'ft' AND osm."cycleway:right" = 'opposite_lane' AND osm."cycleway:right:buffer" IN ('yes','both','right','left'))
);

-- track
UPDATE  neighborhood_ways
SET     tf_bike_infra = 'track'
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND (
            osm."cycleway:both" = 'track'
        OR  (osm."cycleway:left" = 'track' AND osm."oneway:bicycle" = 'no')
        OR  (osm."cycleway:right" = 'track' AND osm."oneway:bicycle" = 'no')
        OR  (osm.cycleway = 'track' AND osm."oneway:bicycle" = 'no')
        OR  (COALESCE(one_way_car,'tf') = 'tf' AND osm."cycleway" = 'track')
        OR  (COALESCE(one_way_car,'tf') = 'tf' AND osm."cycleway:left" = 'track')
        OR  (one_way_car = 'ft' AND osm."cycleway" = 'opposite_track')
        OR  (one_way_car = 'ft' AND osm."cycleway:left" = 'opposite_track')
        OR  (one_way_car = 'ft' AND osm."cycleway:right" = 'opposite_track')
);

-- update one_way based on bike infra
UPDATE  neighborhood_ways
SET     one_way = NULL;
UPDATE  neighborhood_ways
SET     one_way = one_way_car
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND     one_way_car = 'ft'
AND     NOT (tf_bike_infra IS NOT NULL OR COALESCE(osm."oneway:bicycle",'yes') = 'no');
UPDATE  neighborhood_ways
SET     one_way = one_way_car
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND     one_way_car = 'tf'
AND     NOT (ft_bike_infra IS NOT NULL OR COALESCE(osm."oneway:bicycle",'yes') = 'no');
