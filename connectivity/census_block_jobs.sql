----------------------------------------
-- INPUTS
-- location: neighborhood
-- data downloaded from http://lehd.ces.census.gov/data/
-- or http://lehd.ces.census.gov/data/lodes/LODES7/
--     "ma_od_main_JT00_2014".csv
--     ma_od_aux_JT00_2014.csv
-- import to DB and check the block id to have 15 characters
-- also aggregate so 1 block has 1 number of total jobs
--     (total jobs comes from S000 field
--     as per http://lehd.ces.census.gov/data/lodes/LODES7/LODESTechDoc7.2.pdf
----------------------------------------

-- process imported tables
ALTER TABLE "ma_od_aux_JT00_2014" ALTER COLUMN w_geocode TYPE VARCHAR(15);
UPDATE "ma_od_aux_JT00_2014" SET w_geocode = rpad(w_geocode,15,'0'); --just in case we lost any trailing zeros
ALTER TABLE "ma_od_main_JT00_2014" ALTER COLUMN w_geocode TYPE VARCHAR(15);
UPDATE "ma_od_main_JT00_2014" SET w_geocode = rpad(w_geocode,15,'0'); --just in case we lost any trailing zeros

-- indexes
CREATE INDEX tidx_auxjtw ON "ma_od_aux_JT00_2014" (w_geocode);
CREATE INDEX tidx_mainjtw ON "ma_od_main_JT00_2014" (w_geocode);
ANALYZE "ma_od_aux_JT00_2014" (w_geocode);
ANALYZE "ma_od_main_JT00_2014" (w_geocode);

-- create combined table
CREATE TABLE generated.neighborhood_census_block_jobs (
    id SERIAL PRIMARY KEY,
    blockid10 VARCHAR(15),
    jobs INT
);

-- add blocks of interest
INSERT INTO generated.neighborhood_census_block_jobs (blockid10)
SELECT  blocks.blockid10
FROM    neighborhood_census_blocks blocks;

-- add main data
UPDATE  generated.neighborhood_census_block_jobs
SET     jobs = COALESCE((
            SELECT  SUM(j."S000")
            FROM    "ma_od_main_JT00_2014" j
            WHERE   j.w_geocode = neighborhood_census_block_jobs.blockid10
        ),0);

-- add aux data
UPDATE  generated.neighborhood_census_block_jobs
SET     jobs =  jobs +
                COALESCE((
                    SELECT  SUM(j."S000")
                    FROM    "ma_od_aux_JT00_2014" j
                    WHERE   j.w_geocode = neighborhood_census_block_jobs.blockid10
        ),0);

-- indexes
CREATE INDEX idx_neighborhood_blkjobs ON neighborhood_census_block_jobs (blockid10);
ANALYZE neighborhood_census_block_jobs (blockid10);

-- drop import tables
DROP TABLE IF EXISTS "ma_od_aux_JT00_2014";
DROP TABLE IF EXISTS "ma_od_main_JT00_2014";
