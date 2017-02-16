----------------------------------------
-- INPUTS
-- location: neighborhood
-- :nb_boundary_buffer psql var must be set before running this script,
--      e.g. psql -v nb_boundary_buffer=11000 -f connected_census_blocks.sql
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

-- add block pairs
INSERT INTO generated.neighborhood_connected_census_blocks (
    source_blockid10, target_blockid10, low_stress, high_stress
)
SELECT      source_block.blockid10,
            target_block.blockid10,
            FALSE,
            FALSE
FROM        neighborhood_boundary b
JOIN        neighborhood_census_blocks source_block
            ON  ST_Intersects(source_block.geom,b.geom)
JOIN        neighborhood_census_blocks target_block
            ON  source_block.geom <#> target_block.geom < :nb_boundary_buffer;

-- set stress costs
UPDATE      generated.neighborhood_connected_census_blocks
SET         high_stress_cost = (
                SELECT  MIN(agg_cost)
                FROM    pgr_dijkstraCost('
                            SELECT  link_id AS id,
                                    source_vert AS source,
                                    target_vert AS target,
                                    link_cost AS cost
                            FROM    neighborhood_ways_net_link',
                            (
                                SELECT  array_agg(verts.vert_id)
                                FROM    neighborhood_census_block_roads     roads,
                                        neighborhood_ways_net_vert          verts
                                WHERE   source_blockid10 = roads.blockid10
                                        roads.road_id = verts.road_id
                            ),
                            (
                                SELECT  array_agg(verts.vert_id)
                                FROM    neighborhood_census_block_roads     roads,
                                        neighborhood_ways_net_vert          verts
                                WHERE   target_blockid10 = roads.blockid10
                                        roads.road_id = verts.road_id
                            ),
                            directed := true
                        )
            ),
            low_stress_cost = (
                SELECT  MIN(agg_cost)
                FROM    pgr_dijkstraCost('
                            SELECT  link_id AS id,
                                    source_vert AS source,
                                    target_vert AS target,
                                    link_cost AS cost
                            FROM    neighborhood_ways_net_link
                            WHERE   link_stress = 1',
                            (
                                SELECT  array_agg(verts.vert_id)
                                FROM    neighborhood_census_block_roads     roads,
                                        neighborhood_ways_net_vert          verts
                                WHERE   source_blockid10 = roads.blockid10
                                        roads.road_id = verts.road_id
                            ),
                            (
                                SELECT  array_agg(verts.vert_id)
                                FROM    neighborhood_census_block_roads     roads,
                                        neighborhood_ways_net_vert          verts
                                WHERE   target_blockid10 = roads.blockid10
                                        roads.road_id = verts.road_id
                            ),
                            directed := true
                        )
            );

-- block pair index
CREATE UNIQUE INDEX idx_neighborhood_blockpairs ON neighborhood_connected_census_blocks (source_blockid10,target_blockid10);
ANALYZE neighborhood_connected_census_blocks;

-- stress index
CREATE INDEX IF NOT EXISTS idx_neighborhood_blockpairs_lstress ON neighborhood_connected_census_blocks (low_stress) WHERE low_stress IS TRUE;
CREATE INDEX IF NOT EXISTS idx_neighborhood_blockpairs_hstress ON neighborhood_connected_census_blocks (high_stress) WHERE high_stress IS TRUE;
ANALYZE neighborhood_connected_census_blocks;
