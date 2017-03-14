----------------------------------------
-- INPUTS
-- location: neighborhood
-- code to be run on table that has
-- been imported directly from US Census
-- blkpophu file
-- :nb_output_srid psql var must be set before running this script,
--      e.g. psql -v nb_output_srid=2163 -f census_blocks.sql
----------------------------------------

ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS road_ids;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS pop_low_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS pop_high_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS pop_ratio;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS emp_low_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS emp_high_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS emp_ratio;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS schools_low_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS schools_high_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS schools_ratio;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS trails_low_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS trails_high_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS trails_ratio;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS parks_low_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS parks_high_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS parks_ratio;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS community_centers_low_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS community_centers_high_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS community_centers_ratio;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS medical_low_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS medical_high_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS medical_ratio;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS retail_low_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS retail_high_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS retail_ratio;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS social_services_low_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS social_services_high_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS social_services_ratio;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS supermarkets_low_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS supermarkets_high_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS supermarkets_ratio;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS universities_low_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS universities_high_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS universities_ratio;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS colleges_low_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS colleges_high_stress;
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS colleges_ratio;

ALTER TABLE neighborhood_census_blocks ADD COLUMN road_ids INTEGER[];
ALTER TABLE neighborhood_census_blocks ADD COLUMN pop_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN pop_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN pop_ratio FLOAT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN emp_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN emp_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN emp_ratio FLOAT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN schools_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN schools_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN schools_ratio FLOAT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN trails_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN trails_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN trails_ratio FLOAT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN parks_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN parks_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN parks_ratio FLOAT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN community_centers_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN community_centers_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN community_centers_ratio FLOAT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN medical_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN medical_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN medical_ratio FLOAT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN retail_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN retail_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN retail_ratio FLOAT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN social_services_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN social_services_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN social_services_ratio FLOAT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN supermarkets_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN supermarkets_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN supermarkets_ratio FLOAT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN universities_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN universities_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN universities_ratio FLOAT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN colleges_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN colleges_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN colleges_ratio FLOAT;

-- indexes
CREATE INDEX IF NOT EXISTS idx_neighborhood_blocks10 ON neighborhood_census_blocks (blockid10);
CREATE INDEX IF NOT EXISTS idx_neighborhood_geom ON neighborhood_census_blocks USING GIST (geom);
ANALYZE neighborhood_census_blocks;

------------------------------
-- add road_ids
------------------------------
ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS tmp_geom_buffer;
ALTER TABLE neighborhood_census_blocks ADD COLUMN tmp_geom_buffer geometry(multipolygon, :nb_output_srid);

UPDATE  neighborhood_census_blocks
SET     tmp_geom_buffer = ST_Multi(ST_Buffer(geom,15));
CREATE INDEX tsidx_neighborhood_cblockbuffgeoms ON neighborhood_census_blocks USING GIST (tmp_geom_buffer);
ANALYZE neighborhood_census_blocks (tmp_geom_buffer);

UPDATE  neighborhood_census_blocks
SET     road_ids = array((
            SELECT  ways.road_id
            FROM    neighborhood_ways ways
            WHERE   ST_Intersects(neighborhood_census_blocks.tmp_geom_buffer,ways.geom)
            AND     (
                        ST_Contains(neighborhood_census_blocks.tmp_geom_buffer,ways.geom)
                    OR  ST_Length(
                            ST_Intersection(neighborhood_census_blocks.tmp_geom_buffer,ways.geom)
                        ) > 30
                    )
        ));

ALTER TABLE neighborhood_census_blocks DROP COLUMN IF EXISTS tmp_geom_buffer;

-- index
CREATE INDEX aidx_neighborhood_census_blocks_road_ids ON neighborhood_census_blocks USING GIN (road_ids);
ANALYZE neighborhood_census_blocks (road_ids);
