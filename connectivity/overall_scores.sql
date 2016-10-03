----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
DROP TABLE IF EXISTS generated.cambridge_overall_scores;

CREATE TABLE generated.cambridge_overall_scores (
    id SERIAL PRIMARY KEY,
    score_name TEXT,
    score NUMERIC(16,4),
    notes TEXT
);

-- median pop access ratio
INSERT INTO generated.cambridge_overall_scores (
    score_name, score, notes
)
SELECT  'Median ratio of access to population',
        quantile(pop_low_stress::FLOAT/pop_high_stress,0.5),
        'Ratio of population accessible by low stress
        to population accessible overall, expressed as
        the median of all census blocks in the
        neighborhood'
FROM    cambridge_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_zip_codes zips
            WHERE   ST_Intersects(cambridge_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- 70th percentile pop access ratio
INSERT INTO generated.cambridge_overall_scores (
    score_name, score, notes
)
SELECT  '70th percentile ratio of access to population',
        quantile(pop_low_stress::FLOAT/pop_high_stress,0.7),
        'Ratio of population accessible by low stress
        to population accessible overall, expressed as
        the 70th percentile of all census blocks in the
        neighborhood'
FROM    cambridge_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_zip_codes zips
            WHERE   ST_Intersects(cambridge_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- avg pop access ratio
INSERT INTO generated.cambridge_overall_scores (
    score_name, score, notes
)
SELECT  'Average ratio of access to population',
        AVG(pop_low_stress::FLOAT/pop_high_stress),
        'Ratio of population accessible by low stress
        to population accessible overall, expressed as
        the average of all census blocks in the
        neighborhood'
FROM    cambridge_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_zip_codes zips
            WHERE   ST_Intersects(cambridge_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- median jobs access ratio
INSERT INTO generated.cambridge_overall_scores (
    score_name, score, notes
)
SELECT  'Median ratio of access to employment',
        quantile(emp_low_stress::FLOAT/emp_high_stress,0.5),
        'Ratio of employment accessible by low stress
        to employment accessible overall, expressed as
        the median of all census blocks in the
        neighborhood'
FROM    cambridge_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_zip_codes zips
            WHERE   ST_Intersects(cambridge_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- 70th percentile jobs access ratio
INSERT INTO generated.cambridge_overall_scores (
    score_name, score, notes
)
SELECT  '70th percentile ratio of access to employment',
        quantile(emp_low_stress::FLOAT/emp_high_stress,0.7),
        'Ratio of employment accessible by low stress
        to employment accessible overall, expressed as
        the 70th percentile of all census blocks in the
        neighborhood'
FROM    cambridge_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_zip_codes zips
            WHERE   ST_Intersects(cambridge_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- avg jobs access ratio
INSERT INTO generated.cambridge_overall_scores (
    score_name, score, notes
)
SELECT  'Average ratio of access to employment',
        AVG(emp_low_stress::FLOAT/emp_high_stress),
        'Ratio of employment accessible by low stress
        to employment accessible overall, expressed as
        the average of all census blocks in the
        neighborhood'
FROM    cambridge_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_zip_codes zips
            WHERE   ST_Intersects(cambridge_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );
