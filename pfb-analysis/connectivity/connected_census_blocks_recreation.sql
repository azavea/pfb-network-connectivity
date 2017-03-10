----------------------------------------
-- INPUTS
-- location: neighborhood
-- :nb_max_trip_distance psql var must be set before running this script, with a value
--  in the units of the projection used in neighborhood_census_blocks (generally meters)
--      e.g. psql -v nb_max_trip_distance=3300 -f connected_census_blocks_recreation.sql
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_connected_census_blocks_recreation;

CREATE TABLE generated.neighborhood_connected_census_blocks_recreation (
    id SERIAL PRIMARY KEY,
    source_blockid10 VARCHAR(15),
    target_path_id INT,
    low_stress BOOLEAN,
    low_stress_cost INT,
    high_stress BOOLEAN,
    high_stress_cost INT
);

INSERT INTO generated.neighborhood_connected_census_blocks_recreation (
    source_blockid10, target_school_id, low_stress, high_stress
)
SELECT  blocks.blockid10,
        paths.path_id,
        'f'::BOOLEAN,
        't'::BOOLEAN
FROM    neighborhood_census_blocks blocks,
        neighborhood_paths paths
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        )
AND     blocks.geom <#> paths.geom < :nb_max_trip_distance
AND     EXISTS (
            SELECT  1
            FROM    neighborhood_census_block_roads source_br,
                    neighborhood_ways target_r,
                    neighborhood_reachable_roads_high_stress hs
            WHERE   blocks.blockid10 = source_br.blockid10
            AND     paths.path_id = target_r.path_id
            AND     hs.base_road = source_br.road_id
            AND     hs.target_road = target_r.road_id
            AND     paths.path_length > 15840           --path at least 3 mi long
            AND     paths.bbox_length > 10560           --extent of path at least 2 mi long
        );





-- block pair index
CREATE INDEX idx_neighborhood_blockschoolpairs
ON neighborhood_connected_census_blocks_recreation (source_blockid10,target_school_id);
ANALYZE neighborhood_connected_census_blocks_recreation (source_blockid10,target_school_id);

-- low stress
UPDATE  neighborhood_connected_census_blocks_recreation
SET     low_stress = 't'::BOOLEAN
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_census_block_roads source_br,
                    neighborhood_school_roads target_sr,
                    neighborhood_reachable_roads_low_stress ls
            WHERE   source_blockid10 = source_br.blockid10
            AND     target_school_id = target_sr.school_id
            AND     ls.base_road = source_br.road_id
            AND     ls.target_road = target_sr.road_id
        )
AND     (
            SELECT  MIN(total_cost)
            FROM    neighborhood_census_block_roads source_br,
                    neighborhood_school_roads target_sr,
                    neighborhood_reachable_roads_low_stress ls
            WHERE   source_blockid10 = source_br.blockid10
            AND     target_school_id = target_sr.school_id
            AND     ls.base_road = source_br.road_id
            AND     ls.target_road = target_sr.road_id
        )::FLOAT /
        COALESCE((
            SELECT  MIN(total_cost) + 1
            FROM    neighborhood_census_block_roads source_br,
                    neighborhood_school_roads target_sr,
                    neighborhood_reachable_roads_high_stress hs
            WHERE   source_blockid10 = source_br.blockid10
            AND     target_school_id = target_sr.school_id
            AND     hs.base_road = source_br.road_id
            AND     hs.target_road = target_sr.road_id
        ), :nb_max_trip_distance) <= 1.3;

-- stress index
CREATE INDEX idx_neighborhood_blockschl_lstress ON neighborhood_connected_census_blocks_recreation (low_stress);
CREATE INDEX idx_neighborhood_blockschl_hstress ON neighborhood_connected_census_blocks_recreation (high_stress);
ANALYZE neighborhood_connected_census_blocks_recreation (low_stress,high_stress);
