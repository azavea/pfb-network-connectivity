----------------------------------------
-- INPUTS
-- location: neighborhood
-- :nb_boundary_buffer and :nb_output_srid psql vars must be set before running this script,
--      e.g. psql -v nb_boundary_buffer=11000 -v nb_output_srid=2249 -f connected_census_blocks.sql
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
AND     ST_DWithin(source.geom,target.geom,:nb_boundary_buffer);

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
                    ELSE low_stress_cost::FLOAT / high_stress_cost <= 1.3
                    END
        );

-- indexes
CREATE UNIQUE INDEX idx_neighborhood_blockpairs ON neighborhood_connected_census_blocks (source_blockid10,target_blockid10);
CREATE INDEX IF NOT EXISTS idx_neighborhood_blockpairs_lstress ON neighborhood_connected_census_blocks (low_stress) WHERE low_stress IS TRUE;
CREATE INDEX IF NOT EXISTS idx_neighborhood_blockpairs_hstress ON neighborhood_connected_census_blocks (high_stress) WHERE high_stress IS TRUE;
ANALYZE neighborhood_connected_census_blocks;

--
-- INSERT INTO generated.neighborhood_connected_census_blocks (
--     source_blockid10, target_blockid10, low_stress, high_stress
-- )
-- SELECT  source_block.blockid10,
--         target_block.blockid10,
--         'f'::BOOLEAN,
--         't'::BOOLEAN
-- FROM    neighborhood_boundary b
-- JOIN    neighborhood_census_blocks source_block
--         ON  ST_Intersects(source_block.geom,b.geom)
-- JOIN    neighborhood_census_blocks target_block
--         ON  source_block.geom <#> target_block.geom < :nb_boundary_buffer
-- JOIN    neighborhood_census_block_roads source_br
--         ON  source_block.blockid10 = source_br.blockid10
-- JOIN    neighborhood_census_block_roads target_br
--         ON  target_block.blockid10 = target_br.blockid10
-- JOIN    neighborhood_reachable_roads_high_stress hs
--         ON  hs.base_road = source_br.road_id
--         AND hs.target_road = target_br.road_id
-- GROUP BY source_block.blockid10, target_block.blockid10
-- ;
--

--
-- -- low stress
-- UPDATE  neighborhood_connected_census_blocks
-- SET     low_stress = 't'::BOOLEAN
-- WHERE   EXISTS (
--             SELECT  1
--             FROM    neighborhood_census_block_roads source_br,
--                     neighborhood_census_block_roads target_br,
--                     neighborhood_reachable_roads_low_stress ls
--             WHERE   source_blockid10 = source_br.blockid10
--             AND     target_blockid10 = target_br.blockid10
--             AND     ls.base_road = source_br.road_id
--             AND     ls.target_road = target_br.road_id
--         )
-- AND     (
--             SELECT  MIN(total_cost)
--             FROM    neighborhood_census_block_roads source_br,
--                     neighborhood_census_block_roads target_br,
--                     neighborhood_reachable_roads_low_stress ls
--             WHERE   source_blockid10 = source_br.blockid10
--             AND     target_blockid10 = target_br.blockid10
--             AND     ls.base_road = source_br.road_id
--             AND     ls.target_road = target_br.road_id
--         )::FLOAT /
--         COALESCE((
--             SELECT  MIN(total_cost) + 1
--             FROM    neighborhood_census_block_roads source_br,
--                     neighborhood_census_block_roads target_br,
--                     neighborhood_reachable_roads_high_stress hs
--             WHERE   source_blockid10 = source_br.blockid10
--             AND     target_blockid10 = target_br.blockid10
--             AND     hs.base_road = source_br.road_id
--             AND     hs.target_road = target_br.road_id
--         ), :nb_boundary_buffer) <= 1.3;
--
-- -- set low stress for a block connecting to itself
-- UPDATE  neighborhood_connected_census_blocks
-- SET     low_stress = TRUE
-- WHERE   source_blockid10 = target_blockid10;
--
