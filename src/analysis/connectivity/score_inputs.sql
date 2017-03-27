----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_score_inputs;

CREATE TABLE generated.neighborhood_score_inputs (
    id SERIAL PRIMARY KEY,
    category TEXT,
    score_name TEXT,
    score NUMERIC(16,4),
    notes TEXT,
    human_explanation TEXT
);


-------------------------------------
-- population
-------------------------------------
-- median pop access low stress
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Population',
        'Median population accessible by low stress',
        quantile(pop_low_stress,0.5),
        regexp_replace('Total population accessible by low stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of all census blocks in the neighborhood have
            low stress access to more people than this number, half have
            access to fewer people.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median pop access high stress
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Population',
        'Median population accessible by high stress',
        quantile(pop_high_stress,0.5),
        regexp_replace('Total population accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of all census blocks in the neighborhood have
            high stress access to more people than this number, half have
            access to fewer people.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median pop access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Population',
        'Median ratio of access to population',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population accessible by low stress
            to population accessible overall, expressed as
            the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of all census blocks in the neighborhood have
            a ratio of low stress to high stress access above this number,
            half have a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile pop access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Population',
        '70th percentile ratio of access to population',
        quantile(pop_ratio,0.7),
        regexp_replace('Ratio of population accessible by low stress
            to population accessible overall, expressed as
            the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of all census blocks in the neighborhood have
            a ratio of low stress to high stress access above this number,
            70% have a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- avg pop access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Population',
        'Average ratio of access to population',
        AVG(pop_ratio),
        regexp_replace('Ratio of population accessible by low stress
            to population accessible overall, expressed as
            the average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            this ratio of low stress to high stress access.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );


-------------------------------------
-- employment
-------------------------------------
-- median jobs access low stress
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Employment',
        'Median employment accessible by low stress',
        quantile(emp_low_stress,0.5),
        regexp_replace('Total jobs accessible by low stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of all census blocks in the neighborhood have
            low stress access to more jobs than this number, half have
            access to fewer jobs.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median jobs access high stress
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Employment',
        'Median employment accessible by high stress',
        quantile(emp_high_stress,0.5),
        regexp_replace('Total jobs accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of all census blocks in the neighborhood have
            high stress access to more jobs than this number, half have
            access to fewer jobs.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median jobs access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Employment',
        'Median ratio of access to employment',
        quantile(emp_ratio,0.5),
        regexp_replace('Ratio of employment accessible by low stress
            to employment accessible overall, expressed as
            the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of all census blocks in the neighborhood have
            a ratio of low stress to high stress access above this number,
            half have a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile jobs access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Employment',
        '70th percentile ratio of access to employment',
        quantile(emp_ratio,0.7),
        regexp_replace('Ratio of employment accessible by low stress
            to employment accessible overall, expressed as
            the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of all census blocks in the neighborhood have
            a ratio of low stress to high stress access above this number,
            70% have a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- avg jobs access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Employment',
        'Average ratio of access to employment',
        AVG(emp_ratio),
        regexp_replace('Ratio of employment accessible by low stress
            to employment accessible overall, expressed as
            the average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            this ratio of low stress to high stress access.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );


-------------------------------------
-- schools
-------------------------------------
-- median schools access low stress
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Schools',
        'Average low stress school access',
        AVG(schools_low_stress),
        regexp_replace('Number of schools accessible by low stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            low stress access to this many schools.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median schools access high stress
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Schools',
        'Average high stress school access',
        AVG(schools_high_stress),
        regexp_replace('Number of schools accessible by high stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            high stress access to this many schools.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- school low stress pop shed access
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Schools',
        'Average school low stress population shed',
        AVG(pop_low_stress),
        regexp_replace('Population with low stress access to schools
            in the neighborhood expressed as an average of all
            schools in the neighborhood','\n\s+',' '),
        regexp_replace('On average, schools in the neighborhood are connected
            by the low stress access to this many people.','\n\s+',' ')
FROM    neighborhood_schools
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_schools.geom_pt,b.geom)
        );

-- school high stress pop shed access
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Schools',
        'Average school high stress population shed',
        AVG(pop_high_stress),
        regexp_replace('Population with high stress access to schools
            in the neighborhood expressed as an average of all
            schools in the neighborhood','\n\s+',' '),
        regexp_replace('On average, schools in the neighborhood are connected
            by the high stress access to this many people.','\n\s+',' ')
FROM    neighborhood_schools
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_schools.geom_pt,b.geom)
        );

-- school pop shed access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Schools',
        'Average school population shed ratio',
        AVG(pop_low_stress::FLOAT/pop_high_stress),
        regexp_replace('Ratio of population with low stress
            access to schools to population with high stress access
            in the neighborhood expressed as an average of all
            schools in the neighborhood','\n\s+',' '),
        regexp_replace('On average, schools in the neighborhood are connected
            by the low stress access to this many people.','\n\s+',' ')
FROM    neighborhood_schools
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_schools.geom_pt,b.geom)
        );
