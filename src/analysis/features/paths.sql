----------------------------------------
-- INPUTS
-- location: neighborhood
-- proj: :nb_output_srid psql var must be set before running this script,
--       e.g. psql -v nb_output_srid=2163 -f paths.sql
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_paths;
DROP INDEX IF EXISTS idx_neighborhood_ways_path_id;

CREATE TABLE generated.neighborhood_paths (
    path_id SERIAL PRIMARY KEY,
    geom geometry(multilinestring, :nb_output_srid),
    road_ids INTEGER[],
    path_length INTEGER,
    bbox_length INTEGER
);

-- combine contiguous paths
INSERT INTO neighborhood_paths (geom)
SELECT  ST_CollectionExtract(
            ST_SetSRID(
                unnest(ST_ClusterIntersecting(geom)),
                :nb_output_srid
            ),
            2   --linestrings
        )
FROM    neighborhood_ways
WHERE   functional_class = 'path';

-- get raw lengths
UPDATE  neighborhood_paths
SET     path_length = ST_Length(geom);

-- get bounding box lengths
UPDATE  neighborhood_paths
SET     bbox_length = ST_Length(
            ST_SetSRID(
                ST_MakeLine(
                    ST_MakePoint(ST_XMin(geom), ST_YMin(geom)),
                    ST_MakePoint(ST_XMax(geom), ST_YMax(geom))
                ),
                :nb_output_srid
            )
        );

-- index
CREATE INDEX sidx_neighborhood_paths_geom ON neighborhood_paths USING GIST (geom);
ANALYZE neighborhood_paths (geom);

-- set path_id on each road segment (if path)
UPDATE  neighborhood_ways
SET     path_id = (
            SELECT  paths.path_id
            FROM    neighborhood_paths paths
            WHERE   ST_Intersects(neighborhood_ways.geom,paths.geom)
            AND     ST_CoveredBy(neighborhood_ways.geom,paths.geom)
            LIMIT   1
        )
WHERE   functional_class = 'path';

-- get stragglers
UPDATE  neighborhood_ways
SET     path_id = paths.path_id
FROM    neighborhood_paths paths
WHERE   neighborhood_ways.functional_class = 'path'
AND     neighborhood_ways.path_id IS NULL
AND     ST_Intersects(neighborhood_ways.geom,paths.geom)
AND     ST_CoveredBy(neighborhood_ways.geom,ST_Buffer(paths.geom,1));

-- set index
CREATE INDEX idx_neighborhood_ways_path_id ON neighborhood_ways (path_id);
ANALYZE neighborhood_ways (path_id);

-- set road_ids
UPDATE  neighborhood_paths
SET     road_ids = array((
            SELECT  road_id
            FROM    neighborhood_ways
            WHERE   neighborhood_ways.path_id = neighborhood_paths.path_id
        ));

-- index
CREATE INDEX aidx_neighborhood_paths_road_ids ON neighborhood_paths USING GIN (road_ids);
ANALYZE neighborhood_paths (road_ids);
