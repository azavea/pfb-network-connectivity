----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
DROP TABLE IF EXISTS generated.cambridge_paths;
DROP INDEX IF EXISTS idx_cambridge_ways_path_id;

CREATE TABLE generated.cambridge_paths (
    path_id SERIAL PRIMARY KEY,
    geom geometry(multilinestring,2249),
    path_length INTEGER,
    bbox_length INTEGER
);

-- combine contiguous paths
INSERT INTO cambridge_paths (geom)
SELECT  ST_CollectionExtract(
            ST_SetSRID(
                unnest(ST_ClusterIntersecting(geom)),
                2249
            ),
            2   --linestrings
        )
FROM    cambridge_ways
WHERE   functional_class = 'path';

-- get raw lengths
UPDATE  cambridge_paths
SET     path_length = ST_Length(geom);

-- get bounding box lengths
UPDATE  cambridge_paths
SET     bbox_length = ST_Length(
            ST_SetSRID(
                ST_MakeLine(
                    ST_MakePoint(ST_XMin(geom), ST_YMin(geom)),
                    ST_MakePoint(ST_XMax(geom), ST_YMax(geom))
                ),
                2249
            )
        );

-- set path_id on each road segment (if path)
UPDATE  cambridge_ways
SET     path_id = (
            SELECT  paths.path_id
            FROM    cambridge_paths paths
            WHERE   ST_Intersects(cambridge_ways.geom,paths.geom)
            AND     ST_CoveredBy(cambridge_ways.geom,paths.geom)
            LIMIT   1
        )
WHERE   functional_class = 'path';

-- get stragglers
UPDATE  cambridge_ways
SET     path_id = paths.path_id
FROM    cambridge_paths paths
WHERE   cambridge_ways.functional_class = 'path'
AND     cambridge_ways.path_id IS NULL
AND     ST_Intersects(cambridge_ways.geom,paths.geom)
AND     ST_CoveredBy(cambridge_ways.geom,ST_Buffer(paths.geom,1));

-- set index
CREATE INDEX idx_cambridge_ways_path_id ON cambridge_ways (path_id);
ANALYZE cambridge_ways (path_id);
