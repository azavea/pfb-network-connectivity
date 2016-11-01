----------------------------------------
-- INPUTS
-- location: neighborhood
-- code to be run on table that has
-- been imported directly from US Census
-- blkpophu file
----------------------------------------

ALTER TABLE neighborhood_census_blocks ADD COLUMN IF NOT EXISTS pop_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN IF NOT EXISTS pop_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN IF NOT EXISTS emp_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN IF NOT EXISTS emp_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN IF NOT EXISTS schools_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN IF NOT EXISTS schools_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN IF NOT EXISTS rec_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN IF NOT EXISTS rec_high_stress INT;

CREATE INDEX IF NOT EXISTS idx_neighborhood_blocks10 ON neighborhood_census_blocks (blockid10);
CREATE INDEX IF NOT EXISTS idx_neighborhood_geom ON neighborhood_census_blocks USING GIST (geom);
ANALYZE neighborhood_census_blocks;
