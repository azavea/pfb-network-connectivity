----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
DROP TABLE IF EXISTS generated.cambridge_connected_census_blocks_schools;

CREATE TABLE generated.cambridge_connected_census_blocks_schools (
    id SERIAL PRIMARY KEY,
    source_blockid10 VARCHAR(15),
    target_school_id INT,
    low_stress BOOLEAN,
    low_stress_cost INT,
    high_stress BOOLEAN,
    high_stress_cost INT
);

INSERT INTO generated.cambridge_connected_census_blocks_schools (
    source_blockid10, target_school_id, low_stress, high_stress
)
SELECT  blocks.blockid10,
        schools.id,
        'f'::BOOLEAN,
        't'::BOOLEAN
FROM    neighborhood_census_blocks blocks,
        cambridge_schools schools
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(blocks.geom,b.geom)
        )
AND     blocks.geom <#> schools.geom_pt < 11000
AND     EXISTS (
            SELECT  1
            FROM    cambridge_census_block_roads source_br,
                    cambridge_school_roads target_sr,
                    cambridge_reachable_roads_high_stress hs
            WHERE   blocks.blockid10 = source_br.blockid10
            AND     schools.id = target_sr.school_id
            AND     hs.base_road = source_br.road_id
            AND     hs.target_road = target_sr.road_id
        );

-- block pair index
CREATE INDEX idx_cambridge_blockschoolpairs
ON cambridge_connected_census_blocks_schools (source_blockid10,target_school_id);
ANALYZE cambridge_connected_census_blocks_schools (source_blockid10,target_school_id);

-- low stress
UPDATE  cambridge_connected_census_blocks_schools
SET     low_stress = 't'::BOOLEAN
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_census_block_roads source_br,
                    cambridge_school_roads target_sr,
                    cambridge_reachable_roads_low_stress ls
            WHERE   source_blockid10 = source_br.blockid10
            AND     target_school_id = target_sr.school_id
            AND     ls.base_road = source_br.road_id
            AND     ls.target_road = target_sr.road_id
        )
AND     (
            SELECT  MIN(total_cost)
            FROM    cambridge_census_block_roads source_br,
                    cambridge_school_roads target_sr,
                    cambridge_reachable_roads_low_stress ls
            WHERE   source_blockid10 = source_br.blockid10
            AND     target_school_id = target_sr.school_id
            AND     ls.base_road = source_br.road_id
            AND     ls.target_road = target_sr.road_id
        )::FLOAT /
        COALESCE((
            SELECT  MIN(total_cost) + 1
            FROM    cambridge_census_block_roads source_br,
                    cambridge_school_roads target_sr,
                    cambridge_reachable_roads_high_stress hs
            WHERE   source_blockid10 = source_br.blockid10
            AND     target_school_id = target_sr.school_id
            AND     hs.base_road = source_br.road_id
            AND     hs.target_road = target_sr.road_id
        ),11000) <= 1.3;

-- stress index
CREATE INDEX idx_cambridge_blockschl_lstress ON cambridge_connected_census_blocks_schools (low_stress);
CREATE INDEX idx_cambridge_blockschl_hstress ON cambridge_connected_census_blocks_schools (high_stress);
ANALYZE cambridge_connected_census_blocks_schools (low_stress,high_stress);
