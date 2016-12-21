----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_overall_scores;

CREATE TABLE generated.neighborhood_overall_scores (
    id SERIAL PRIMARY KEY,
    category TEXT,
    score_name TEXT,
    score NUMERIC(16,4),
    notes TEXT
);

-- median pop access low stress
INSERT INTO generated.neighborhood_overall_scores (
    category, score_name, score, notes
)
SELECT  'Population',
        'Median population accessible by low stress',
        quantile(pop_low_stress,0.5),
        regexp_replace('Total population accessible by low stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- median pop access high stress
INSERT INTO generated.neighborhood_overall_scores (
    category, score_name, score, notes
)
SELECT  'Population',
        'Median population accessible by high stress',
        quantile(pop_high_stress,0.5),
        regexp_replace('Total population accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- median pop access ratio
INSERT INTO generated.neighborhood_overall_scores (
    category, score_name, score, notes
)
SELECT  'Population',
        'Median ratio of access to population',
        quantile(pop_low_stress::FLOAT/pop_high_stress,0.5),
        regexp_replace('Ratio of population accessible by low stress
            to population accessible overall, expressed as
            the median of all census blocks in the
            neighborhood','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- 70th percentile pop access ratio
INSERT INTO generated.neighborhood_overall_scores (
    category, score_name, score, notes
)
SELECT  'Population',
        '70th percentile ratio of access to population',
        quantile(pop_low_stress::FLOAT/pop_high_stress,0.7),
        regexp_replace('Ratio of population accessible by low stress
            to population accessible overall, expressed as
            the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- avg pop access ratio
INSERT INTO generated.neighborhood_overall_scores (
    category, score_name, score, notes
)
SELECT  'Population',
        'Average ratio of access to population',
        AVG(pop_low_stress::FLOAT/pop_high_stress),
        regexp_replace('Ratio of population accessible by low stress
            to population accessible overall, expressed as
            the average of all census blocks in the
            neighborhood','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- median jobs access low stress
INSERT INTO generated.neighborhood_overall_scores (
    category, score_name, score, notes
)
SELECT  'Employment',
        'Median employment accessible by low stress',
        quantile(emp_low_stress,0.5),
        regexp_replace('Total jobs accessible by low stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- median jobs access high stress
INSERT INTO generated.neighborhood_overall_scores (
    category, score_name, score, notes
)
SELECT  'Employment',
        'Median employment accessible by high stress',
        quantile(emp_high_stress,0.5),
        regexp_replace('Total jobs accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- median jobs access ratio
INSERT INTO generated.neighborhood_overall_scores (
    category, score_name, score, notes
)
SELECT  'Employment',
        'Median ratio of access to employment',
        quantile(emp_low_stress::FLOAT/emp_high_stress,0.5),
        regexp_replace('Ratio of employment accessible by low stress
            to employment accessible overall, expressed as
            the median of all census blocks in the
            neighborhood','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- 70th percentile jobs access ratio
INSERT INTO generated.neighborhood_overall_scores (
    category, score_name, score, notes
)
SELECT  'Employment',
        '70th percentile ratio of access to employment',
        quantile(emp_low_stress::FLOAT/emp_high_stress,0.7),
        regexp_replace('Ratio of employment accessible by low stress
            to employment accessible overall, expressed as
            the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- avg jobs access ratio
INSERT INTO generated.neighborhood_overall_scores (
    category, score_name, score, notes
)
SELECT  'Employment',
        'Average ratio of access to employment',
        AVG(emp_low_stress::FLOAT/emp_high_stress),
        regexp_replace('Ratio of employment accessible by low stress
            to employment accessible overall, expressed as
            the average of all census blocks in the
            neighborhood','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- median schools access low stress
INSERT INTO generated.neighborhood_overall_scores (
    category, score_name, score, notes
)
SELECT  'Schools',
        'Average low stress school access',
        AVG(schools_low_stress),
        regexp_replace('Number of schools accessible by low stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- median schools access high stress
INSERT INTO generated.neighborhood_overall_scores (
    category, score_name, score, notes
)
SELECT  'Schools',
        'Average high stress school access',
        AVG(schools_high_stress),
        regexp_replace('Number of schools accessible by high stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- school low stress pop shed access
INSERT INTO generated.neighborhood_overall_scores (
    category, score_name, score, notes
)
SELECT  'Schools',
        'Average school low stress population shed',
        AVG(pop_low_stress),
        regexp_replace('Population with low stress access to schools
            in the neighborhood expressed as an average of all
            schools in the neighborhood','\n\s+',' ')
FROM    neighborhood_schools
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_schools.geom_pt,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- school high stress pop shed access
INSERT INTO generated.neighborhood_overall_scores (
    category, score_name, score, notes
)
SELECT  'Schools',
        'Average school high stress population shed',
        AVG(pop_high_stress),
        regexp_replace('Population with high stress access to schools
            in the neighborhood expressed as an average of all
            schools in the neighborhood','\n\s+',' ')
FROM    neighborhood_schools
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_schools.geom_pt,zips.geom)
            AND     zips.zip_code = '02138'
        );

-- school pop shed access ratio
INSERT INTO generated.neighborhood_overall_scores (
    category, score_name, score, notes
)
SELECT  'Schools',
        'Average school population shed ratio',
        AVG(pop_low_stress::FLOAT/pop_high_stress),
        regexp_replace('Ratio of population with low stress
            access to schools to population with high stress access
            in the neighborhood expressed as an average of all
            schools in the neighborhood','\n\s+',' ')
FROM    neighborhood_schools
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(neighborhood_schools.geom_pt,zips.geom)
            AND     zips.zip_code = '02138'
        );
