----------------------------------------
-- INPUTS
-- location: neighborhood
-- code to be run on table that has
-- been imported directly from US Census
-- blkpophu file
----------------------------------------

ALTER TABLE neighborhood_census_blocks ADD COLUMN pop_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN pop_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN emp_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN emp_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN schools_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN schools_high_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN rec_low_stress INT;
ALTER TABLE neighborhood_census_blocks ADD COLUMN rec_high_stress INT;

CREATE INDEX idx_neighborhood_blocks10 ON neighborhood_census_blocks (blockid10);
ANALYZE neighborhood_census_blocks (blockid10);
