----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
UPDATE  cambridge_ways SET width_ft = NULL;

-- first forward/backward (if given)
-- feet
UPDATE  cambridge_ways
SET     width_ft = substring(osm.width FROM '\d+\.?\d?\d?')::FLOAT
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.width LIKE '% ft'
AND     osm.width LIKE '%forward%';
UPDATE  cambridge_ways
SET     width_ft = COALESCE(width_ft,0) + substring(osm.width FROM '\d+\.?\d?\d?')::FLOAT
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.width LIKE '% ft'
AND     osm.width LIKE '%backward%';

-- meters
UPDATE  cambridge_ways
SET     width_ft = 3.28084 * substring(osm.width FROM '\d+\.?\d?\d?')::FLOAT
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.width LIKE '% m'
AND     osm.width LIKE '%forward%';
UPDATE  cambridge_ways
SET     width_ft = COALESCE(width_ft,0) +
            (3.28084 * substring(osm.width FROM '\d+\.?\d?\d?')::FLOAT)
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.width LIKE '% m'
AND     osm.width LIKE '%backward%';

-- no units (default=meters)
-- N.B. we weed out anything more than 20, since that's likely either bogus
-- or not in meters
UPDATE  cambridge_ways
SET     width_ft = 3.28084 * substring(osm.width FROM '\d+\.?\d?\d?')::FLOAT
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.width NOT LIKE '% m'
AND     osm.width NOT LIKE '% ft'
AND     osm.width LIKE '%forward%';
UPDATE  cambridge_ways
SET     width_ft = COALESCE(width_ft,0) +
            (3.28084 * substring(osm.width FROM '\d+\.?\d?\d?')::FLOAT)
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     NOT osm.width LIKE '% m'
AND     NOT osm.width LIKE '% ft'
AND     osm.width LIKE '%backward%';

-- then singles
-- feet
UPDATE  cambridge_ways
SET     width_ft = substring(osm.width from '\d+\.?\d?\d?')::FLOAT
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.width IS NOT NULL
AND     NOT osm.width LIKE '%forward%'
AND     NOT osm.width LIKE '%backward%'
AND     osm.width LIKE '% ft';

-- meters
UPDATE  cambridge_ways
SET     width_ft = 3.28084 * substring(osm.width from '\d+\.?\d?\d?')::FLOAT
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.width IS NOT NULL
AND     NOT osm.width LIKE '%forward%'
AND     NOT osm.width LIKE '%backward%'
AND     osm.width LIKE '% m';

-- no units (default=meters)
-- N.B. we weed out anything more than 20, since that's likely either bogus
-- or not in meters
UPDATE  cambridge_ways
SET     width_ft = 3.28084 * substring(osm.width from '\d+\.?\d?\d?')::FLOAT
FROM    cambridge_osm_full_line osm
WHERE   cambridge_ways.osm_id = osm.osm_id
AND     osm.width IS NOT NULL
AND     NOT osm.width LIKE '%forward%'
AND     NOT osm.width LIKE '%backward%'
AND     substring(osm.width from '\d+\.?\d?\d?')::FLOAT < 20;
