----------------------------------------
-- INPUTS
-- location: cambridge
-- code to be run on table that has
-- been imported directly from US Census
-- blkpophu file
----------------------------------------

ALTER TABLE cambridge_census_blocks ADD COLUMN pop_low_stress INT;
ALTER TABLE cambridge_census_blocks ADD COLUMN pop_high_stress INT;
ALTER TABLE cambridge_census_blocks ADD COLUMN emp_low_stress INT;
ALTER TABLE cambridge_census_blocks ADD COLUMN emp_high_stress INT;
ALTER TABLE cambridge_census_blocks ADD COLUMN schools_low_stress INT;
ALTER TABLE cambridge_census_blocks ADD COLUMN schools_high_stress INT;

CREATE INDEX idx_cambridge_blocks10 ON cambridge_census_blocks (blockid10);
ANALYZE cambridge_census_blocks (blockid10);
