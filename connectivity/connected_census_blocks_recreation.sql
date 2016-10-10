----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
DROP TABLE IF EXISTS generated.cambridge_connected_census_blocks_recreation;

CREATE TABLE generated.cambridge_connected_census_blocks_recreation (
    id SERIAL PRIMARY KEY,
    source_blockid10 VARCHAR(15),
    target_path_id INT,
    low_stress BOOLEAN,
    low_stress_cost INT,
    high_stress BOOLEAN,
    high_stress_cost INT
);

INSERT INTO generated.cambridge_connected_census_blocks_recreation (
    source_blockid10, target_school_id, low_stress, high_stress
)
SELECT  blocks.blockid10,
        schools.id,
        'f'::BOOLEAN,
        't'::BOOLEAN
FROM    cambridge_census_blocks blocks,
        cambridge_paths paths
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_zip_codes zips
            WHERE   ST_Intersects(blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        )
AND     blocks.geom <#> paths.geom < 11000
AND     EXISTS (
            SELECT  1
            FROM    cambridge_census_block_roads source_br,
                    cambridge_ways target_r,
                    cambridge_reachable_roads_high_stress hs
            WHERE   blocks.blockid10 = source_br.blockid10
            AND     paths.path_id = target_r.path_id
            AND     hs.base_road = source_br.road_id
            AND     hs.target_road = target_sr.road_id
        );

-- block pair index
CREATE INDEX idx_cambridge_blockschoolpairs
ON cambridge_connected_census_blocks_recreation (source_blockid10,target_school_id);
ANALYZE cambridge_connected_census_blocks_recreation (source_blockid10,target_school_id);

-- low stress
UPDATE  cambridge_connected_census_blocks_recreation
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
CREATE INDEX idx_cambridge_blockschl_lstress ON cambridge_connected_census_blocks_recreation (low_stress);
CREATE INDEX idx_cambridge_blockschl_hstress ON cambridge_connected_census_blocks_recreation (high_stress);
ANALYZE cambridge_connected_census_blocks_recreation (low_stress,high_stress);
