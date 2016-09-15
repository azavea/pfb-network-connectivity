-- remove non-highways and unbikeable links
DELETE FROM boston_massachusetts_osm_line WHERE highway IS NULL;
DELETE FROM boston_massachusetts_osm_line WHERE highway IN (
    'proposed','steps','track','construction','corridor','crossing','elevator',
    'platform','unsurfaced'
);

UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = NULL,
        seg_stress_tf = NULL;

-- paths
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 1,
        seg_stress_tf = 1
WHERE   highway IN ('cycleway','path','living_street')
OR      (highway = 'pedestrian' AND bicycle IN ('designated','destination','yes'))
OR      (highway = 'footway' AND bicycle IN ('designated','destination','yes'));

-- motorways
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   highway IN ('motorway','motorway_link');

-- residential
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 1,
        seg_stress_tf = 1
WHERE   highway = 'residential';

------------------------------------------------------
-- handle cases where speed limit and lanes present
------------------------------------------------------
-- bike lanes
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 1,
        seg_stress_tf = 1
WHERE   lanes::INT IN (1,2,3)
AND     speed::INT = 25
AND     (bicycle='lane' OR cycleway='lane')
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   lanes::INT IN (4,5)
AND     speed::INT = 25
AND     (bicycle='lane' OR cycleway='lane')
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   lanes::INT IN (1,2,3)
AND     speed::INT = 30
AND     (bicycle='lane' OR cycleway='lane')
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   lanes::INT > 5
AND     speed::INT = 25
AND     (bicycle='lane' OR cycleway='lane')
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   lanes::INT IN (4,5)
AND     speed::INT = 30
AND     (bicycle='lane' OR cycleway='lane')
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   lanes::INT > 5
AND     speed::INT = 30
AND     (bicycle='lane' OR cycleway='lane')
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   lanes::INT IN (1,2,3)
AND     speed::INT >= 35
AND     (bicycle='lane' OR cycleway='lane')
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   lanes::INT IN (4,5)
AND     speed::INT >= 35
AND     (bicycle='lane' OR cycleway='lane')
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   lanes::INT > 5
AND     speed::INT >= 35
AND     (bicycle='lane' OR cycleway='lane')
AND     seg_stress_ft IS NULL;

-- buffered bike lanes
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 1,
        seg_stress_tf = 1
WHERE   lanes::INT IN (1,2,3)
AND     speed::INT = 25
AND     cycleway='buffered_lane'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   lanes::INT IN (4,5)
AND     speed::INT = 25
AND     cycleway='buffered_lane'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   lanes::INT IN (1,2,3)
AND     speed::INT = 30
AND     cycleway='buffered_lane'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   lanes::INT > 5
AND     speed::INT = 25
AND     cycleway='buffered_lane'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   lanes::INT IN (4,5)
AND     speed::INT = 30
AND     cycleway='buffered_lane'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   lanes::INT > 5
AND     speed::INT = 30
AND     cycleway='buffered_lane'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   lanes::INT IN (1,2,3)
AND     speed::INT >= 35
AND     cycleway='buffered_lane'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   lanes::INT IN (4,5)
AND     speed::INT >= 35
AND     cycleway='buffered_lane'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   lanes::INT > 5
AND     speed::INT >= 35
AND     cycleway='buffered_lane'
AND     seg_stress_ft IS NULL;

-- protected bike lanes
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 1,
        seg_stress_tf = 1
WHERE   lanes::INT IN (1,2,3)
AND     speed::INT = 25
AND     cycleway='track'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 1,
        seg_stress_tf = 1
WHERE   lanes::INT IN (4,5)
AND     speed::INT = 25
AND     cycleway='track'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 1,
        seg_stress_tf = 1
WHERE   lanes::INT IN (1,2,3)
AND     speed::INT = 30
AND     cycleway='track'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   lanes::INT > 5
AND     speed::INT = 25
AND     cycleway='track'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   lanes::INT IN (4,5)
AND     speed::INT = 30
AND     cycleway='track'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   lanes::INT > 5
AND     speed::INT = 30
AND     cycleway='track'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   lanes::INT IN (1,2,3)
AND     speed::INT >= 35
AND     cycleway='track'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   lanes::INT IN (4,5)
AND     speed::INT >= 35
AND     cycleway='track'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   lanes::INT > 5
AND     speed::INT >= 35
AND     cycleway='track'
AND     seg_stress_ft IS NULL;

-- shared
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   lanes::INT IN (1,2,3)
AND     speed::INT = 25
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   lanes::INT IN (4,5)
AND     speed::INT = 25
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   lanes::INT IN (1,2,3)
AND     speed::INT = 30
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   lanes::INT > 5
AND     speed::INT = 25
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   lanes::INT IN (4,5)
AND     speed::INT = 30
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   lanes::INT > 5
AND     speed::INT = 30
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   lanes::INT IN (1,2,3)
AND     speed::INT >= 35
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   lanes::INT IN (4,5)
AND     speed::INT >= 35
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   lanes::INT > 5
AND     speed::INT >= 35
AND     seg_stress_ft IS NULL;


------------------------------------------------------
-- handle speeds but no lane data
------------------------------------------------------
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   speed::INT >= 35
AND     seg_stress_ft IS NULL;

-- 25
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   speed::INT = 25
AND     highway IN ('primary','primary_link','trunk','trunk_link')
AND     cycleway = 'track'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   speed::INT = 25
AND     highway IN ('primary','primary_link','trunk','trunk_link')
AND     (bicycle='lane' OR cycleway IN ('lane','buffered_lane'))
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 1,
        seg_stress_tf = 1
WHERE   speed::INT = 25
AND     highway IN ('tertiary','tertiary_link','secondary','secondary_link')
AND     cycleway IN ('buffered_lane','track')
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   speed::INT = 25
AND     highway IN ('tertiary','tertiary_link','secondary','secondary_link')
AND     (bicycle='lane' OR cycleway IN ('lane'))
AND     seg_stress_ft IS NULL;

-- 30
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   speed::INT = 30
AND     highway IN ('primary','primary_link','trunk','trunk_link')
AND     cycleway = 'track'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   speed::INT = 30
AND     highway IN ('primary','primary_link','trunk','trunk_link')
AND     (bicycle='lane' OR cycleway IN ('lane','buffered_lane'))
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   speed::INT = 30
AND     highway IN ('tertiary','tertiary_link','secondary','secondary_link')
AND     cycleway IN ('buffered_lane','track')
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   speed::INT = 30
AND     highway IN ('tertiary','tertiary_link','secondary','secondary_link')
AND     seg_stress_ft IS NULL;

-- anything primary/trunk without bike facilities
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   speed IS NOT NULL
AND     highway IN ('primary','primary_link','trunk','trunk_link')
AND     seg_stress_ft IS NULL;

-- anything with speed > 30
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   speed::INT > 30
AND     seg_stress_ft IS NULL;

------------------------------------------------------
-- lane data but no speeds
------------------------------------------------------
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   lanes::INT > 5
AND     seg_stress_ft IS NULL;

-- 2-3
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 1,
        seg_stress_tf = 1
WHERE   lanes::INT IN (1,2,3)
AND     highway IN ('tertiary','tertiary_link','secondary','secondary_link')
AND     (bicycle='lane' OR cycleway IN ('lane','buffered_lane','track'))
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   lanes::INT IN (1,2,3)
AND     highway IN ('tertiary','tertiary_link')
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   lanes::INT IN (1,2,3)
AND     highway IN ('secondary','secondary_link')
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   lanes::INT IN (1,2,3)
AND     highway IN ('primary','primary_link','trunk','trunk_link')
AND     seg_stress_ft IS NULL;

-- 4-5
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   lanes::INT IN (4,5)
AND     highway IN ('tertiary','tertiary_link','secondary','secondary_link')
AND     cycleway IN ('track')
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   lanes::INT IN (4,5)
AND     highway IN ('tertiary','tertiary_link','secondary','secondary_link')
AND     seg_stress_ft IS NULL;

-- anything primary/trunk without bike facilities
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   lanes IS NOT NULL
AND     highway IN ('primary','primary_link','trunk','trunk_link')
AND     seg_stress_ft IS NULL;

--anything more than 5 lanes
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   lanes::INT > 5
AND     seg_stress_ft IS NULL;


------------------------------------------------------
-- no lane or speed data
------------------------------------------------------
-- bike lanes
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   highway IN ('tertiary','tertiary_link')
AND     (bicycle='lane' OR cycleway = 'lane')
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   (bicycle='lane' OR cycleway = 'lane')
AND     seg_stress_ft IS NULL;

-- buffered lanes
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   highway IN ('tertiary','tertiary_link')
AND     cycleway = 'buffered_lane'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   highway IN ('secondary','secondary_link')
AND     cycleway = 'buffered_lane'
AND     seg_stress_ft IS NULL;

-- tracks
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 1,
        seg_stress_tf = 1
WHERE   highway IN ('tertiary','tertiary_link','secondary','secondary_link')
AND     cycleway = 'track'
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 2,
        seg_stress_tf = 2
WHERE   cycleway = 'track'
AND     seg_stress_ft IS NULL;

-- shared
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 3,
        seg_stress_tf = 3
WHERE   highway IN ('tertiary','tertiary_link')
AND     seg_stress_ft IS NULL;
UPDATE  boston_massachusetts_osm_line
SET     seg_stress_ft = 4,
        seg_stress_tf = 4
WHERE   highway IN ('secondary','secondary_link')
AND     seg_stress_ft IS NULL;
-- UPDATE  boston_massachusetts_osm_line
-- SET     seg_stress_ft = 4,
--         seg_stress_tf = 4
-- WHERE   seg_stress_ft IS NULL;
