----------------------------------------
-- INPUTS
-- location: neighborhood
-- :nb_max_trip_distance and :nb_output_srid psql vars must be set before running this script,
--      e.g. psql -v nb_max_trip_distance=2680 -v nb_output_srid=2163 -f connected_census_blocks.sql
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_connected_census_blocks;

CREATE TABLE generated.neighborhood_connected_census_blocks (
    id SERIAL PRIMARY KEY,
    source_blockid10 VARCHAR(15),
    target_blockid10 VARCHAR(15),
    low_stress BOOLEAN,
    low_stress_cost INT,
    high_stress BOOLEAN,
    high_stress_cost INT
);

INSERT INTO generated.neighborhood_connected_census_blocks (
    source_blockid10, target_blockid10,
    low_stress, low_stress_cost, high_stress, high_stress_cost
)
SELECT  source.blockid10,
        target.blockid10,
        FALSE,
        (
            SELECT  MIN(ls.total_cost)
            FROM    neighborhood_reachable_roads_low_stress ls
            WHERE   ls.base_road = ANY(source.road_ids)
            AND     ls.target_road = ANY(target.road_ids)
        ),
        TRUE,
        (
            SELECT  MIN(hs.total_cost)
            FROM    neighborhood_reachable_roads_low_stress hs
            WHERE   hs.base_road = ANY(source.road_ids)
            AND     hs.target_road = ANY(target.road_ids)
        )
FROM    neighborhood_census_blocks source,
        neighborhood_census_blocks target,
        neighborhood_boundary
WHERE   ST_Intersects(source.geom,neighborhood_boundary.geom)
AND     ST_DWithin(source.geom,target.geom,:nb_max_trip_distance);

-- set low_stress
UPDATE  generated.neighborhood_connected_census_blocks
SET     low_stress = TRUE
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_census_blocks source,
                    neighborhood_census_blocks target
            WHERE   neighborhood_connected_census_blocks.source_blockid10 = source.blockid10
            AND     neighborhood_connected_census_blocks.target_blockid10 = target.blockid10
            AND     source.road_ids && target.road_ids
        )
OR      (
            low_stress_cost IS NOT NULL
        AND CASE    WHEN COALESCE(high_stress_cost,0) = 0 THEN TRUE
                    ELSE low_stress_cost::FLOAT / high_stress_cost <= 1.25
                    END
        );

-- indexes
CREATE UNIQUE INDEX idx_neighborhood_blockpairs ON neighborhood_connected_census_blocks (source_blockid10,target_blockid10);
CREATE INDEX IF NOT EXISTS idx_neighborhood_blockpairs_lstress ON neighborhood_connected_census_blocks (low_stress) WHERE low_stress IS TRUE;
CREATE INDEX IF NOT EXISTS idx_neighborhood_blockpairs_hstress ON neighborhood_connected_census_blocks (high_stress) WHERE high_stress IS TRUE;
ANALYZE neighborhood_connected_census_blocks;
