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
    human_explanation TEXT,
    use_pop BOOLEAN,
    use_emp BOOLEAN,
    use_k12 BOOLEAN,
    use_tech BOOLEAN,
    use_univ BOOLEAN,
    use_doctor BOOLEAN,
    use_dentist BOOLEAN,
    use_hospital BOOLEAN,
    use_pharmacy BOOLEAN,
    use_retail BOOLEAN,
    use_grocery BOOLEAN,
    use_social_svcs BOOLEAN,
    use_parks BOOLEAN,
    use_trails BOOLEAN,
    use_comm_ctrs BOOLEAN,
    use_transit BOOLEAN
);


-------------------------------------
-- population
-------------------------------------
-- median pop access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_pop
)
SELECT  'People',
        'Median ratio of access to population',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population accessible by low stress
            to population accessible overall, expressed as
            the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of all census blocks in the neighborhood have
            a ratio of low stress to high stress access above this number,
            half have a lower ratio.','\n\s+',' '),
        True
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
SELECT  'People',
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

-- 30th percentile pop access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'People',
        '30th percentile ratio of access to population',
        quantile(pop_ratio,0.3),
        regexp_replace('Ratio of population accessible by low stress
            to population accessible overall, expressed as
            the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of all census blocks in the neighborhood have
            a ratio of low stress to high stress access above this number,
            30% have a lower ratio.','\n\s+',' ')
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
SELECT  'People',
        'Average ratio of access to population',
        CASE    WHEN SUM(pop_high_stress) = 0 THEN 0
                ELSE SUM(pop_low_stress)::FLOAT / SUM(pop_high_stress)
                END,
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
-- median jobs access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_emp
)
SELECT  'Opportunity',
        'Median ratio of access to employment',
        quantile(emp_ratio,0.5),
        regexp_replace('Ratio of employment accessible by low stress
            to employment accessible overall, expressed as
            the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of all census blocks in the neighborhood have
            a ratio of low stress to high stress access above this number,
            half have a lower ratio.','\n\s+',' '),
        True
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
SELECT  'Opportunity',
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

-- 30th percentile jobs access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile ratio of access to employment',
        quantile(emp_ratio,0.3),
        regexp_replace('Ratio of employment accessible by low stress
            to employment accessible overall, expressed as
            the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of all census blocks in the neighborhood have
            a ratio of low stress to high stress access above this number,
            30% have a lower ratio.','\n\s+',' ')
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
SELECT  'Opportunity',
        'Average ratio of access to employment',
        CASE    WHEN SUM(emp_high_stress) = 0 THEN 0
                ELSE SUM(emp_low_stress)::FLOAT / SUM(emp_high_stress)
                END,
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
-- average school access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average ratio of low stress access to schools',
        CASE    WHEN SUM(schools_high_stress) = 0 THEN 0
                ELSE SUM(schools_low_stress) / SUM(schools_high_stress)
                END,
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

-- median schools access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Median ratio of school access',
        quantile(schools_ratio,0.5),
        regexp_replace('Ratio of schools accessible by low stress
            compared to schools accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of census blocks in this neighborhood
            have low stress access to a higher ratio of schools within
            biking distance, half have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile schools access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile ratio of school access',
        quantile(schools_ratio,0.7),
        regexp_replace('Ratio of schools accessible by low stress
            compared to schools accessible by high stress
            expressed as the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of census blocks in this neighborhood
            have low stress access to a higher ratio of schools within
            biking distance, 70% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 30th percentile schools access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile ratio of school access',
        quantile(schools_ratio,0.3),
        regexp_replace('Ratio of schools accessible by low stress
            compared to schools accessible by high stress
            expressed as the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of census blocks in this neighborhood
            have low stress access to a higher ratio of schools within
            biking distance, 30% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- school pop shed average low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average school bike shed access ratio',
        CASE    WHEN SUM(pop_high_stress) = 0 THEN 0
                ELSE SUM(pop_low_stress)::FLOAT / SUM(pop_high_stress)
                END,
        regexp_replace('Ratio of population with low stress access
            compared to total population within the bike shed distance
            of schools in the neighborhood expressed as an average of
            all schools in the neighborhood','\n\s+',' '),
        regexp_replace('On average, schools in the neighborhood are
            connected by the low stress access to this percentage people
            within biking distance.','\n\s+',' ')
FROM    neighborhood_schools
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_schools.geom_pt,b.geom)
        );

-- school pop shed median low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Median school population shed ratio',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population with low stress access to schools
            in the neighborhood to total population within the bike shed
            of each school expressed as a median of all
            schools in the neighborhood','\n\s+',' '),
        regexp_replace('Half of schools in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, half are connected to a lower percentage.','\n\s+',' ')
FROM    neighborhood_schools
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_schools.geom_pt,b.geom)
        );

-- school pop shed 70th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile school population shed ratio',
        quantile(pop_ratio,0.7),
        regexp_replace('Ratio of population with low stress access to schools
            in the neighborhood to total population within the bike shed
            of each school expressed as the 70th percentile of all
            schools in the neighborhood','\n\s+',' '),
        regexp_replace('30% of schools in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 70% are connected to a lower percentage.','\n\s+',' ')
FROM    neighborhood_schools
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_schools.geom_pt,b.geom)
        );

-- school pop shed 30th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_k12
)
SELECT  'Opportunity',
        '30th percentile school population shed ratio',
        quantile(pop_ratio,0.3),
        regexp_replace('Ratio of population with low stress access to schools
            in the neighborhood to total population within the bike shed
            of each school expressed as the 30th percentile of all
            schools in the neighborhood','\n\s+',' '),
        regexp_replace('70% of schools in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 30% are connected to a lower percentage.','\n\s+',' '),
        True
FROM    neighborhood_schools
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_schools.geom_pt,b.geom)
        );


-------------------------------------
-- technical/vocational colleges
-------------------------------------
-- average technical/vocational college access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average ratio of low stress access to tech/vocational colleges',
        CASE    WHEN SUM(colleges_high_stress) = 0 THEN 0
                ELSE SUM(colleges_low_stress) / SUM(colleges_high_stress)
                END,
        regexp_replace('Number of tech/vocational colleges accessible by low stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            low stress access to this many tech/vocational colleges.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median colleges access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Median ratio of tech/vocational college access',
        quantile(colleges_ratio,0.5),
        regexp_replace('Ratio of tech/vocational colleges accessible by low stress
            compared to tech/vocational colleges accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of census blocks in this neighborhood
            have low stress access to a higher ratio of tech/vocational colleges within
            biking distance, half have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile colleges access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile ratio of tech/vocational college access',
        quantile(colleges_ratio,0.7),
        regexp_replace('Ratio of tech/vocational colleges accessible by low stress
            compared to tech/vocational colleges accessible by high stress
            expressed as the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of census blocks in this neighborhood
            have low stress access to a higher ratio of tech/vocational colleges within
            biking distance, 70% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 30th percentile colleges access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile ratio of tech/vocational college access',
        quantile(colleges_ratio,0.3),
        regexp_replace('Ratio of tech/vocational colleges accessible by low stress
            compared to tech/vocational colleges accessible by high stress
            expressed as the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of census blocks in this neighborhood
            have low stress access to a higher ratio of tech/vocational colleges within
            biking distance, 30% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- college pop shed average low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average college bike shed access ratio',
        CASE    WHEN SUM(pop_high_stress) = 0 THEN 0
                ELSE SUM(pop_low_stress)::FLOAT / SUM(pop_high_stress)
                END,
        regexp_replace('Ratio of population with low stress access
            compared to total population within the bike shed distance
            of tech/vocational colleges in the neighborhood expressed as an average of
            all colleges in the neighborhood','\n\s+',' '),
        regexp_replace('On average, colleges in the neighborhood are
            connected by the low stress access to this percentage people
            within biking distance.','\n\s+',' ')
FROM    neighborhood_colleges
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_colleges.geom_pt,b.geom)
        );

-- college pop shed median low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_tech
)
SELECT  'Opportunity',
        'Median tech/vocational college population shed ratio',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population with low stress access to tech/vocational colleges
            in the neighborhood to total population within the bike shed
            of each college expressed as a median of all
            colleges in the neighborhood','\n\s+',' '),
        regexp_replace('Half of tech/vocational colleges in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, half are connected to a lower percentage.
            (if only one tech/vocational college exists this is the score for that one
            location)','\n\s+',' '),
        True
FROM    neighborhood_colleges
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_colleges.geom_pt,b.geom)
        );

-- college pop shed 70th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile tech/vocational college population shed ratio',
        quantile(pop_ratio,0.7),
        regexp_replace('Ratio of population with low stress access to tech/vocational colleges
            in the neighborhood to total population within the bike shed
            of each college expressed as the 70th percentile of all
            colleges in the neighborhood','\n\s+',' '),
        regexp_replace('30% of tech/vocational colleges in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 70% are connected to a lower percentage.
            (if only one tech/vocational college exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_colleges
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_colleges.geom_pt,b.geom)
        );

-- college pop shed 30th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile tech/vocational college population shed ratio',
        quantile(pop_ratio,0.3),
        regexp_replace('Ratio of population with low stress access to tech/vocational colleges
            in the neighborhood to total population within the bike shed
            of each college expressed as the 30th percentile of all
            colleges in the neighborhood','\n\s+',' '),
        regexp_replace('70% of tech/vocational colleges in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 30% are connected to a lower percentage.
            (if only one tech/vocational college exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_colleges
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_colleges.geom_pt,b.geom)
        );


-------------------------------------
-- universities
-------------------------------------
-- average university access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average ratio of low stress access to universities',
        CASE    WHEN SUM(universities_high_stress) = 0 THEN 0
                ELSE SUM(universities_low_stress) / SUM(universities_high_stress)
                END,
        regexp_replace('Number of universities accessible by low stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            low stress access to this many universities.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median universities access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Median ratio of university access',
        quantile(universities_ratio,0.5),
        regexp_replace('Ratio of universities accessible by low stress
            compared to universities accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of census blocks in this neighborhood
            have low stress access to a higher ratio of universities within
            biking distance, half have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile universities access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile ratio of university access',
        quantile(universities_ratio,0.7),
        regexp_replace('Ratio of universities accessible by low stress
            compared to universities accessible by high stress
            expressed as the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of census blocks in this neighborhood
            have low stress access to a higher ratio of universities within
            biking distance, 70% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 30th percentile universities access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile ratio of university access',
        quantile(universities_ratio,0.3),
        regexp_replace('Ratio of universities accessible by low stress
            compared to universities accessible by high stress
            expressed as the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of census blocks in this neighborhood
            have low stress access to a higher ratio of universities within
            biking distance, 30% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- university pop shed average low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average university bike shed access ratio',
        CASE    WHEN SUM(pop_high_stress) = 0 THEN 0
                ELSE SUM(pop_low_stress)::FLOAT / SUM(pop_high_stress)
                END,
        regexp_replace('Ratio of population with low stress access
            compared to total population within the bike shed distance
            of universities in the neighborhood expressed as an average of
            all universities in the neighborhood','\n\s+',' '),
        regexp_replace('On average, universities in the neighborhood are
            connected by the low stress access to this percentage people
            within biking distance.','\n\s+',' ')
FROM    neighborhood_universities
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_universities.geom_pt,b.geom)
        );

-- university pop shed median low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_univ
)
SELECT  'Opportunity',
        'Median university population shed ratio',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population with low stress access to universities
            in the neighborhood to total population within the bike shed
            of each university expressed as a median of all
            universities in the neighborhood','\n\s+',' '),
        regexp_replace('Half of universities in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, half are connected to a lower percentage.
            (if only one university exists this is the score for that one
            location)','\n\s+',' '),
        True
FROM    neighborhood_universities
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_universities.geom_pt,b.geom)
        );

-- university pop shed 70th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile university population shed ratio',
        quantile(pop_ratio,0.7),
        regexp_replace('Ratio of population with low stress access to universities
            in the neighborhood to total population within the bike shed
            of each university expressed as the 70th percentile of all
            universities in the neighborhood','\n\s+',' '),
        regexp_replace('30% of universities in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 70% are connected to a lower percentage.
            (if only one university exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_universities
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_universities.geom_pt,b.geom)
        );

-- university pop shed 30th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile university population shed ratio',
        quantile(pop_ratio,0.3),
        regexp_replace('Ratio of population with low stress access to universities
            in the neighborhood to total population within the bike shed
            of each university expressed as the 30th percentile of all
            universities in the neighborhood','\n\s+',' '),
        regexp_replace('70% of universities in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 30% are connected to a lower percentage.
            (if only one university exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_universities
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_universities.geom_pt,b.geom)
        );


-------------------------------------
-- doctors
-------------------------------------
-- average doctors access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average ratio of low stress access to doctors',
        CASE    WHEN SUM(doctors_high_stress) = 0 THEN 0
                ELSE SUM(doctors_low_stress) / SUM(doctors_high_stress)
                END,
        regexp_replace('Number of doctors accessible by low stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            low stress access to this many doctors.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median doctors access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Median ratio of doctors access',
        quantile(doctors_ratio,0.5),
        regexp_replace('Ratio of doctors accessible by low stress
            compared to doctors accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of census blocks in this neighborhood
            have low stress access to a higher ratio of doctors within
            biking distance, half have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile doctors access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile ratio of doctors access',
        quantile(doctors_ratio,0.7),
        regexp_replace('Ratio of doctors accessible by low stress
            compared to doctors accessible by high stress
            expressed as the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of census blocks in this neighborhood
            have low stress access to a higher ratio of doctors within
            biking distance, 70% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 30th percentile doctors access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile ratio of doctors access',
        quantile(doctors_ratio,0.3),
        regexp_replace('Ratio of doctors accessible by low stress
            compared to doctors accessible by high stress
            expressed as the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of census blocks in this neighborhood
            have low stress access to a higher ratio of doctors within
            biking distance, 30% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- doctors pop shed average low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average doctors bike shed access ratio',
        CASE    WHEN SUM(pop_high_stress) = 0 THEN 0
                ELSE SUM(pop_low_stress)::FLOAT / SUM(pop_high_stress)
                END,
        regexp_replace('Ratio of population with low stress access
            compared to total population within the bike shed distance
            of doctors in the neighborhood expressed as an average of
            all doctors in the neighborhood','\n\s+',' '),
        regexp_replace('On average, doctors in the neighborhood are
            connected by the low stress access to this percentage people
            within biking distance.','\n\s+',' ')
FROM    neighborhood_doctors
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_doctors.geom_pt,b.geom)
        );

-- doctors pop shed median low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_doctor
)
SELECT  'Opportunity',
        'Median doctors population shed ratio',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population with low stress access to doctors
            in the neighborhood to total population within the bike shed
            of each doctors office expressed as a median of all
            doctors in the neighborhood','\n\s+',' '),
        regexp_replace('Half of doctors in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, half are connected to a lower percentage.
            (if only one doctors office exists this is the score for that one
            location)','\n\s+',' '),
        True
FROM    neighborhood_doctors
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_doctors.geom_pt,b.geom)
        );

-- doctors pop shed 70th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile doctors population shed ratio',
        quantile(pop_ratio,0.7),
        regexp_replace('Ratio of population with low stress access to doctors
            in the neighborhood to total population within the bike shed
            of each doctors office expressed as the 70th percentile of all
            doctors in the neighborhood','\n\s+',' '),
        regexp_replace('30% of doctors in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 70% are connected to a lower percentage.
            (if only one doctors exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_doctors
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_doctors.geom_pt,b.geom)
        );

-- doctors pop shed 30th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile doctors population shed ratio',
        quantile(pop_ratio,0.3),
        regexp_replace('Ratio of population with low stress access to doctors
            in the neighborhood to total population within the bike shed
            of each doctors office expressed as the 30th percentile of all
            doctors in the neighborhood','\n\s+',' '),
        regexp_replace('70% of doctors in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 30% are connected to a lower percentage.
            (if only one doctors exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_doctors
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_doctors.geom_pt,b.geom)
        );

-------------------------------------
-- dentists
-------------------------------------
-- average dentists access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average ratio of low stress access to dentists',
        CASE    WHEN SUM(dentists_high_stress) = 0 THEN 0
                ELSE SUM(dentists_low_stress) / SUM(dentists_high_stress)
                END,
        regexp_replace('Number of dentists accessible by low stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            low stress access to this many dentists.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median dentists access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Median ratio of dentists access',
        quantile(dentists_ratio,0.5),
        regexp_replace('Ratio of dentists accessible by low stress
            compared to dentists accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of census blocks in this neighborhood
            have low stress access to a higher ratio of dentists within
            biking distance, half have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile dentists access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile ratio of dentists access',
        quantile(dentists_ratio,0.7),
        regexp_replace('Ratio of dentists accessible by low stress
            compared to dentists accessible by high stress
            expressed as the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of census blocks in this neighborhood
            have low stress access to a higher ratio of dentists within
            biking distance, 70% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 30th percentile dentists access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile ratio of dentists access',
        quantile(dentists_ratio,0.3),
        regexp_replace('Ratio of dentists accessible by low stress
            compared to dentists accessible by high stress
            expressed as the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of census blocks in this neighborhood
            have low stress access to a higher ratio of dentists within
            biking distance, 30% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- dentists pop shed average low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average dentists bike shed access ratio',
        CASE    WHEN SUM(pop_high_stress) = 0 THEN 0
                ELSE SUM(pop_low_stress)::FLOAT / SUM(pop_high_stress)
                END,
        regexp_replace('Ratio of population with low stress access
            compared to total population within the bike shed distance
            of dentists in the neighborhood expressed as an average of
            all dentists in the neighborhood','\n\s+',' '),
        regexp_replace('On average, dentists in the neighborhood are
            connected by the low stress access to this percentage people
            within biking distance.','\n\s+',' ')
FROM    neighborhood_dentists
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_dentists.geom_pt,b.geom)
        );

-- dentists pop shed median low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_dentist
)
SELECT  'Opportunity',
        'Median dentists population shed ratio',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population with low stress access to dentists
            in the neighborhood to total population within the bike shed
            of each dentists office expressed as a median of all
            dentists in the neighborhood','\n\s+',' '),
        regexp_replace('Half of dentists in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, half are connected to a lower percentage.
            (if only one dentists office exists this is the score for that one
            location)','\n\s+',' '),
        True
FROM    neighborhood_dentists
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_dentists.geom_pt,b.geom)
        );

-- dentists pop shed 70th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile dentists population shed ratio',
        quantile(pop_ratio,0.7),
        regexp_replace('Ratio of population with low stress access to dentists
            in the neighborhood to total population within the bike shed
            of each dentists office expressed as the 70th percentile of all
            dentists in the neighborhood','\n\s+',' '),
        regexp_replace('30% of dentists in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 70% are connected to a lower percentage.
            (if only one dentists office exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_dentists
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_dentists.geom_pt,b.geom)
        );

-- dentists pop shed 30th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile dentists population shed ratio',
        quantile(pop_ratio,0.3),
        regexp_replace('Ratio of population with low stress access to dentists
            in the neighborhood to total population within the bike shed
            of each dentists office expressed as the 30th percentile of all
            dentists in the neighborhood','\n\s+',' '),
        regexp_replace('70% of dentists in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 30% are connected to a lower percentage.
            (if only one dentists office exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_dentists
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_dentists.geom_pt,b.geom)
        );

-------------------------------------
-- hospitals
-------------------------------------
-- average hospitals access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average ratio of low stress access to hospitals',
        CASE    WHEN SUM(hospitals_high_stress) = 0 THEN 0
                ELSE SUM(hospitals_low_stress) / SUM(hospitals_high_stress)
                END,
        regexp_replace('Number of hospitals accessible by low stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            low stress access to this many hospitals.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median hospitals access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Median ratio of hospitals access',
        quantile(hospitals_ratio,0.5),
        regexp_replace('Ratio of hospitals accessible by low stress
            compared to hospitals accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of census blocks in this neighborhood
            have low stress access to a higher ratio of hospitals within
            biking distance, half have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile hospitals access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile ratio of hospitals access',
        quantile(hospitals_ratio,0.7),
        regexp_replace('Ratio of hospitals accessible by low stress
            compared to hospitals accessible by high stress
            expressed as the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of census blocks in this neighborhood
            have low stress access to a higher ratio of hospitals within
            biking distance, 70% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 30th percentile hospitals access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile ratio of hospitals access',
        quantile(hospitals_ratio,0.3),
        regexp_replace('Ratio of hospitals accessible by low stress
            compared to hospitals accessible by high stress
            expressed as the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of census blocks in this neighborhood
            have low stress access to a higher ratio of hospitals within
            biking distance, 30% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- hospitals pop shed average low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average hospitals bike shed access ratio',
        CASE    WHEN SUM(pop_high_stress) = 0 THEN 0
                ELSE SUM(pop_low_stress)::FLOAT / SUM(pop_high_stress)
                END,
        regexp_replace('Ratio of population with low stress access
            compared to total population within the bike shed distance
            of hospitals in the neighborhood expressed as an average of
            all hospitals in the neighborhood','\n\s+',' '),
        regexp_replace('On average, hospitals in the neighborhood are
            connected by the low stress access to this percentage people
            within biking distance.','\n\s+',' ')
FROM    neighborhood_hospitals
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_hospitals.geom_pt,b.geom)
        );

-- hospitals pop shed median low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_hospital
)
SELECT  'Opportunity',
        'Median hospitals population shed ratio',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population with low stress access to hospitals
            in the neighborhood to total population within the bike shed
            of each hospital expressed as a median of all
            hospitals in the neighborhood','\n\s+',' '),
        regexp_replace('Half of hospitals in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, half are connected to a lower percentage.
            (if only one hospital exists this is the score for that one
            location)','\n\s+',' '),
        True
FROM    neighborhood_hospitals
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_hospitals.geom_pt,b.geom)
        );

-- hospitals pop shed 70th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile hospitals population shed ratio',
        quantile(pop_ratio,0.7),
        regexp_replace('Ratio of population with low stress access to hospitals
            in the neighborhood to total population within the bike shed
            of each hospital expressed as the 70th percentile of all
            hospitals in the neighborhood','\n\s+',' '),
        regexp_replace('30% of hospitals in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 70% are connected to a lower percentage.
            (if only one hospital exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_hospitals
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_hospitals.geom_pt,b.geom)
        );

-- hospitals pop shed 30th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile hospitals population shed ratio',
        quantile(pop_ratio,0.3),
        regexp_replace('Ratio of population with low stress access to hospitals
            in the neighborhood to total population within the bike shed
            of each hospital expressed as the 30th percentile of all
            hospitals in the neighborhood','\n\s+',' '),
        regexp_replace('70% of hospitals in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 30% are connected to a lower percentage.
            (if only one hospital exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_hospitals
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_hospitals.geom_pt,b.geom)
        );

-------------------------------------
-- pharmacies
-------------------------------------
-- average pharmacies access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average ratio of low stress access to pharmacies',
        CASE    WHEN SUM(pharmacies_high_stress) = 0 THEN 0
                ELSE SUM(pharmacies_low_stress) / SUM(pharmacies_high_stress)
                END,
        regexp_replace('Number of pharmacies accessible by low stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            low stress access to this many pharmacies.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median pharmacies access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Median ratio of pharmacies access',
        quantile(pharmacies_ratio,0.5),
        regexp_replace('Ratio of pharmacies accessible by low stress
            compared to pharmacies accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of census blocks in this neighborhood
            have low stress access to a higher ratio of pharmacies within
            biking distance, half have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile pharmacies access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile ratio of pharmacies access',
        quantile(pharmacies_ratio,0.7),
        regexp_replace('Ratio of pharmacies accessible by low stress
            compared to pharmacies accessible by high stress
            expressed as the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of census blocks in this neighborhood
            have low stress access to a higher ratio of pharmacies within
            biking distance, 70% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 30th percentile pharmacies access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile ratio of pharmacies access',
        quantile(pharmacies_ratio,0.3),
        regexp_replace('Ratio of pharmacies accessible by low stress
            compared to pharmacies accessible by high stress
            expressed as the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of census blocks in this neighborhood
            have low stress access to a higher ratio of pharmacies within
            biking distance, 30% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- pharmacies pop shed average low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average pharmacies bike shed access ratio',
        CASE    WHEN SUM(pop_high_stress) = 0 THEN 0
                ELSE SUM(pop_low_stress)::FLOAT / SUM(pop_high_stress)
                END,
        regexp_replace('Ratio of population with low stress access
            compared to total population within the bike shed distance
            of pharmacies in the neighborhood expressed as an average of
            all pharmacies in the neighborhood','\n\s+',' '),
        regexp_replace('On average, pharmacies in the neighborhood are
            connected by the low stress access to this percentage people
            within biking distance.','\n\s+',' ')
FROM    neighborhood_pharmacies
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_pharmacies.geom_pt,b.geom)
        );

-- pharmacies pop shed median low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_pharmacy
)
SELECT  'Opportunity',
        'Median pharmacies population shed ratio',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population with low stress access to pharmacies
            in the neighborhood to total population within the bike shed
            of each pharmacy expressed as a median of all
            pharmacies in the neighborhood','\n\s+',' '),
        regexp_replace('Half of pharmacies in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, half are connected to a lower percentage.
            (if only one pharmacy exists this is the score for that one
            location)','\n\s+',' '),
        True
FROM    neighborhood_pharmacies
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_pharmacies.geom_pt,b.geom)
        );

-- pharmacies pop shed 70th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile pharmacies population shed ratio',
        quantile(pop_ratio,0.7),
        regexp_replace('Ratio of population with low stress access to pharmacies
            in the neighborhood to total population within the bike shed
            of each pharmacy expressed as the 70th percentile of all
            pharmacies in the neighborhood','\n\s+',' '),
        regexp_replace('30% of pharmacies in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 70% are connected to a lower percentage.
            (if only one pharmacy exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_pharmacies
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_pharmacies.geom_pt,b.geom)
        );

-- pharmacies pop shed 30th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile pharmacies population shed ratio',
        quantile(pop_ratio,0.3),
        regexp_replace('Ratio of population with low stress access to pharmacies
            in the neighborhood to total population within the bike shed
            of each pharmacy expressed as the 30th percentile of all
            pharmacies in the neighborhood','\n\s+',' '),
        regexp_replace('70% of pharmacies in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 30% are connected to a lower percentage.
            (if only one pharmacy exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_pharmacies
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_pharmacies.geom_pt,b.geom)
        );

-------------------------------------
-- retail
-------------------------------------
-- average retail access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average ratio of low stress access to retail',
        CASE    WHEN SUM(retail_high_stress) = 0 THEN 0
                ELSE SUM(retail_low_stress) / SUM(retail_high_stress)
                END,
        regexp_replace('Number of retail accessible by low stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            low stress access to this many retail.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median retail access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Median ratio of retail access',
        quantile(retail_ratio,0.5),
        regexp_replace('Ratio of retail accessible by low stress
            compared to retail accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of census blocks in this neighborhood
            have low stress access to a higher ratio of retail within
            biking distance, half have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile retail access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile ratio of retail access',
        quantile(retail_ratio,0.7),
        regexp_replace('Ratio of retail accessible by low stress
            compared to retail accessible by high stress
            expressed as the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of census blocks in this neighborhood
            have low stress access to a higher ratio of retail within
            biking distance, 70% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 30th percentile retail access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile ratio of retail access',
        quantile(retail_ratio,0.3),
        regexp_replace('Ratio of retail accessible by low stress
            compared to retail accessible by high stress
            expressed as the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of census blocks in this neighborhood
            have low stress access to a higher ratio of retail within
            biking distance, 30% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- retail pop shed average low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average retail bike shed access ratio',
        CASE    WHEN SUM(pop_high_stress) = 0 THEN 0
                ELSE SUM(pop_low_stress)::FLOAT / SUM(pop_high_stress)
                END,
        regexp_replace('Ratio of population with low stress access
            compared to total population within the bike shed distance
            of retail clusters in the neighborhood expressed as an average of
            all retail clusters in the neighborhood','\n\s+',' '),
        regexp_replace('On average, retail clusters in the neighborhood are
            connected by the low stress access to this percentage people
            within biking distance.','\n\s+',' ')
FROM    neighborhood_retail
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_retail.geom_pt,b.geom)
        );

-- retail pop shed median low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_retail
)
SELECT  'Opportunity',
        'Median retail population shed ratio',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population with low stress access to retail
            in the neighborhood to total population within the bike shed
            of each retail cluster expressed as a median of all
            retail clusters in the neighborhood','\n\s+',' '),
        regexp_replace('Half of retail clusters in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, half are connected to a lower percentage.
            (if only one retail exists this is the score for that one
            location)','\n\s+',' '),
        True
FROM    neighborhood_retail
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_retail.geom_pt,b.geom)
        );

-- retail pop shed 70th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile retail population shed ratio',
        quantile(pop_ratio,0.7),
        regexp_replace('Ratio of population with low stress access to retail
            in the neighborhood to total population within the bike shed
            of each retail cluster expressed as the 70th percentile of all
            retail clusters in the neighborhood','\n\s+',' '),
        regexp_replace('30% of retail clusters in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 70% are connected to a lower percentage.
            (if only one retail exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_retail
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_retail.geom_pt,b.geom)
        );

-- retail pop shed 30th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile retail population shed ratio',
        quantile(pop_ratio,0.3),
        regexp_replace('Ratio of population with low stress access to retail
            in the neighborhood to total population within the bike shed
            of each retail cluster expressed as the 30th percentile of all
            retail clusters in the neighborhood','\n\s+',' '),
        regexp_replace('70% of retail clusters in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 30% are connected to a lower percentage.
            (if only one retail exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_retail
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_retail.geom_pt,b.geom)
        );

-------------------------------------
-- supermarkets
-------------------------------------
-- average supermarkets access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average ratio of low stress access to supermarkets',
        CASE    WHEN SUM(supermarkets_high_stress) = 0 THEN 0
                ELSE SUM(supermarkets_low_stress) / SUM(supermarkets_high_stress)
                END,
        regexp_replace('Number of supermarkets accessible by low stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            low stress access to this many supermarkets.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median supermarkets access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Median ratio of supermarkets access',
        quantile(supermarkets_ratio,0.5),
        regexp_replace('Ratio of supermarkets accessible by low stress
            compared to supermarkets accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of census blocks in this neighborhood
            have low stress access to a higher ratio of supermarkets within
            biking distance, half have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile supermarkets access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile ratio of supermarkets access',
        quantile(supermarkets_ratio,0.7),
        regexp_replace('Ratio of supermarkets accessible by low stress
            compared to supermarkets accessible by high stress
            expressed as the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of census blocks in this neighborhood
            have low stress access to a higher ratio of supermarkets within
            biking distance, 70% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 30th percentile supermarkets access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile ratio of supermarkets access',
        quantile(supermarkets_ratio,0.3),
        regexp_replace('Ratio of supermarkets accessible by low stress
            compared to supermarkets accessible by high stress
            expressed as the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of census blocks in this neighborhood
            have low stress access to a higher ratio of supermarkets within
            biking distance, 30% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- supermarkets pop shed average low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average supermarkets bike shed access ratio',
        CASE    WHEN SUM(pop_high_stress) = 0 THEN 0
                ELSE SUM(pop_low_stress)::FLOAT / SUM(pop_high_stress)
                END,
        regexp_replace('Ratio of population with low stress access
            compared to total population within the bike shed distance
            of supermarkets in the neighborhood expressed as an average of
            all supermarkets in the neighborhood','\n\s+',' '),
        regexp_replace('On average, supermarkets in the neighborhood are
            connected by the low stress access to this percentage people
            within biking distance.','\n\s+',' ')
FROM    neighborhood_supermarkets
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_supermarkets.geom_pt,b.geom)
        );

-- supermarkets pop shed median low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_grocery
)
SELECT  'Opportunity',
        'Median supermarkets population shed ratio',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population with low stress access to supermarkets
            in the neighborhood to total population within the bike shed
            of each supermarket expressed as a median of all
            supermarkets in the neighborhood','\n\s+',' '),
        regexp_replace('Half of supermarkets in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, half are connected to a lower percentage.
            (if only one supermarkets exists this is the score for that one
            location)','\n\s+',' '),
        True
FROM    neighborhood_supermarkets
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_supermarkets.geom_pt,b.geom)
        );

-- supermarkets pop shed 70th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile supermarkets population shed ratio',
        quantile(pop_ratio,0.7),
        regexp_replace('Ratio of population with low stress access to supermarkets
            in the neighborhood to total population within the bike shed
            of each supermarket expressed as the 70th percentile of all
            supermarkets in the neighborhood','\n\s+',' '),
        regexp_replace('30% of supermarkets in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 70% are connected to a lower percentage.
            (if only one supermarkets exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_supermarkets
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_supermarkets.geom_pt,b.geom)
        );

-- supermarkets pop shed 30th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile supermarkets population shed ratio',
        quantile(pop_ratio,0.3),
        regexp_replace('Ratio of population with low stress access to supermarkets
            in the neighborhood to total population within the bike shed
            of each supermarket expressed as the 30th percentile of all
            supermarkets in the neighborhood','\n\s+',' '),
        regexp_replace('70% of supermarkets in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 30% are connected to a lower percentage.
            (if only one supermarkets exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_supermarkets
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_supermarkets.geom_pt,b.geom)
        );

-------------------------------------
-- social_services
-------------------------------------
-- average social_services access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average ratio of low stress access to social services',
        CASE    WHEN SUM(social_services_high_stress) = 0 THEN 0
                ELSE SUM(social_services_low_stress) / SUM(social_services_high_stress)
                END,
        regexp_replace('Number of social services accessible by low stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            low stress access to this many social services.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median social_services access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Median ratio of social services access',
        quantile(social_services_ratio,0.5),
        regexp_replace('Ratio of social services accessible by low stress
            compared to social services accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of census blocks in this neighborhood
            have low stress access to a higher ratio of social services within
            biking distance, half have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile social_services access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile ratio of social services access',
        quantile(social_services_ratio,0.7),
        regexp_replace('Ratio of social services accessible by low stress
            compared to social services accessible by high stress
            expressed as the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of census blocks in this neighborhood
            have low stress access to a higher ratio of social services within
            biking distance, 70% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 30th percentile social_services access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile ratio of social services access',
        quantile(social_services_ratio,0.3),
        regexp_replace('Ratio of social services accessible by low stress
            compared to social services accessible by high stress
            expressed as the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of census blocks in this neighborhood
            have low stress access to a higher ratio of social services within
            biking distance, 30% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- social_services pop shed average low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average social_services bike shed access ratio',
        CASE    WHEN SUM(pop_high_stress) = 0 THEN 0
                ELSE SUM(pop_low_stress)::FLOAT / SUM(pop_high_stress)
                END,
        regexp_replace('Ratio of population with low stress access
            compared to total population within the bike shed distance
            of social services in the neighborhood expressed as an average of
            all social services in the neighborhood','\n\s+',' '),
        regexp_replace('On average, social_services in the neighborhood are
            connected by the low stress access to this percentage people
            within biking distance.','\n\s+',' ')
FROM    neighborhood_social_services
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_social_services.geom_pt,b.geom)
        );

-- social_services pop shed median low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_social_svcs
)
SELECT  'Opportunity',
        'Median social_services population shed ratio',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population with low stress access to social services
            in the neighborhood to total population within the bike shed
            of each social service location expressed as a median of all
            social services in the neighborhood','\n\s+',' '),
        regexp_replace('Half of social services in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, half are connected to a lower percentage.
            (if only one social_services exists this is the score for that one
            location)','\n\s+',' '),
        True
FROM    neighborhood_social_services
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_social_services.geom_pt,b.geom)
        );

-- social_services pop shed 70th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile social_services population shed ratio',
        quantile(pop_ratio,0.7),
        regexp_replace('Ratio of population with low stress access to social services
            in the neighborhood to total population within the bike shed
            of each social service location expressed as the 70th percentile of all
            social services in the neighborhood','\n\s+',' '),
        regexp_replace('30% of social services in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 70% are connected to a lower percentage.
            (if only one social_services exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_social_services
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_social_services.geom_pt,b.geom)
        );

-- social_services pop shed 30th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile social_services population shed ratio',
        quantile(pop_ratio,0.3),
        regexp_replace('Ratio of population with low stress access to social services
            in the neighborhood to total population within the bike shed
            of each social service location expressed as the 30th percentile of all
            social services in the neighborhood','\n\s+',' '),
        regexp_replace('70% of social services in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 30% are connected to a lower percentage.
            (if only one social_services exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_social_services
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_social_services.geom_pt,b.geom)
        );

-------------------------------------
-- parks
-------------------------------------
-- average parks access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average ratio of low stress access to parks',
        CASE    WHEN SUM(parks_high_stress) = 0 THEN 0
                ELSE SUM(parks_low_stress) / SUM(parks_high_stress)
                END,
        regexp_replace('Number of parks accessible by low stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            low stress access to this many parks.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median parks access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_parks
)
SELECT  'Opportunity',
        'Median ratio of parks access',
        quantile(parks_ratio,0.5),
        regexp_replace('Ratio of parks accessible by low stress
            compared to parks accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of census blocks in this neighborhood
            have low stress access to a higher ratio of parks within
            biking distance, half have access to a lower ratio.','\n\s+',' '),
        True
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile parks access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile ratio of parks access',
        quantile(parks_ratio,0.7),
        regexp_replace('Ratio of parks accessible by low stress
            compared to parks accessible by high stress
            expressed as the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of census blocks in this neighborhood
            have low stress access to a higher ratio of parks within
            biking distance, 70% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 30th percentile parks access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile ratio of parks access',
        quantile(parks_ratio,0.3),
        regexp_replace('Ratio of parks accessible by low stress
            compared to parks accessible by high stress
            expressed as the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of census blocks in this neighborhood
            have low stress access to a higher ratio of parks within
            biking distance, 30% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- parks pop shed average low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average parks bike shed access ratio',
        CASE    WHEN SUM(pop_high_stress) = 0 THEN 0
                ELSE SUM(pop_low_stress)::FLOAT / SUM(pop_high_stress)
                END,
        regexp_replace('Ratio of population with low stress access
            compared to total population within the bike shed distance
            of parks in the neighborhood expressed as an average of
            all parks in the neighborhood','\n\s+',' '),
        regexp_replace('On average, parks in the neighborhood are
            connected by the low stress access to this percentage people
            within biking distance.','\n\s+',' ')
FROM    neighborhood_parks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_parks.geom_pt,b.geom)
        );

-- parks pop shed median low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Median parks population shed ratio',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population with low stress access to parks
            in the neighborhood to total population within the bike shed
            of each parks expressed as a median of all
            parks in the neighborhood','\n\s+',' '),
        regexp_replace('Half of parks in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, half are connected to a lower percentage.
            (if only one parks exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_parks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_parks.geom_pt,b.geom)
        );

-- parks pop shed 70th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile parks population shed ratio',
        quantile(pop_ratio,0.7),
        regexp_replace('Ratio of population with low stress access to parks
            in the neighborhood to total population within the bike shed
            of each parks expressed as the 70th percentile of all
            parks in the neighborhood','\n\s+',' '),
        regexp_replace('30% of parks in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 70% are connected to a lower percentage.
            (if only one parks exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_parks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_parks.geom_pt,b.geom)
        );

-- parks pop shed 30th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile parks population shed ratio',
        quantile(pop_ratio,0.3),
        regexp_replace('Ratio of population with low stress access to parks
            in the neighborhood to total population within the bike shed
            of each parks expressed as the 30th percentile of all
            parks in the neighborhood','\n\s+',' '),
        regexp_replace('70% of parks in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 30% are connected to a lower percentage.
            (if only one parks exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_parks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_parks.geom_pt,b.geom)
        );

-------------------------------------
-- trails
-------------------------------------
-- average trails access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average ratio of low stress access to trails',
        CASE    WHEN SUM(trails_high_stress) = 0 THEN 0
                ELSE SUM(trails_low_stress) / SUM(trails_high_stress)
                END,
        regexp_replace('Number of trails accessible by low stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            low stress access to this many trails.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median trails access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_trails
)
SELECT  'Opportunity',
        'Median ratio of trails access',
        quantile(trails_ratio,0.5),
        regexp_replace('Ratio of trails accessible by low stress
            compared to trails accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of census blocks in this neighborhood
            have low stress access to a higher ratio of trails within
            biking distance, half have access to a lower ratio.','\n\s+',' '),
        True
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile trails access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile ratio of trails access',
        quantile(trails_ratio,0.7),
        regexp_replace('Ratio of trails accessible by low stress
            compared to trails accessible by high stress
            expressed as the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of census blocks in this neighborhood
            have low stress access to a higher ratio of trails within
            biking distance, 70% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 30th percentile trails access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile ratio of trails access',
        quantile(trails_ratio,0.3),
        regexp_replace('Ratio of trails accessible by low stress
            compared to trails accessible by high stress
            expressed as the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of census blocks in this neighborhood
            have low stress access to a higher ratio of trails within
            biking distance, 30% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- trails pop shed average low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average trails bike shed access ratio',
        CASE    WHEN SUM(pop_high_stress) = 0 THEN 0
                ELSE SUM(pop_low_stress)::FLOAT / SUM(pop_high_stress)
                END,
        regexp_replace('Ratio of population with low stress access
            compared to total population within the bike shed distance
            of trails in the neighborhood expressed as an average of
            all trails in the neighborhood','\n\s+',' '),
        regexp_replace('On average, trails in the neighborhood are
            connected by the low stress access to this percentage people
            within biking distance.','\n\s+',' ')
FROM    neighborhood_trails
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_trails.geom_pt,b.geom)
        );

-- trails pop shed median low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Median trails population shed ratio',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population with low stress access to trails
            in the neighborhood to total population within the bike shed
            of each trails expressed as a median of all
            trails in the neighborhood','\n\s+',' '),
        regexp_replace('Half of trails in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, half are connected to a lower percentage.
            (if only one trails exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_trails
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_trails.geom_pt,b.geom)
        );

-- trails pop shed 70th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile trails population shed ratio',
        quantile(pop_ratio,0.7),
        regexp_replace('Ratio of population with low stress access to trails
            in the neighborhood to total population within the bike shed
            of each trails expressed as the 70th percentile of all
            trails in the neighborhood','\n\s+',' '),
        regexp_replace('30% of trails in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 70% are connected to a lower percentage.
            (if only one trails exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_trails
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_trails.geom_pt,b.geom)
        );

-- trails pop shed 30th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile trails population shed ratio',
        quantile(pop_ratio,0.3),
        regexp_replace('Ratio of population with low stress access to trails
            in the neighborhood to total population within the bike shed
            of each trails expressed as the 30th percentile of all
            trails in the neighborhood','\n\s+',' '),
        regexp_replace('70% of trails in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 30% are connected to a lower percentage.
            (if only one trails exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_trails
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_trails.geom_pt,b.geom)
        );

-------------------------------------
-- community_centers
-------------------------------------
-- average community_centers access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average ratio of low stress access to community centers',
        CASE    WHEN SUM(community_centers_high_stress) = 0 THEN 0
                ELSE SUM(community_centers_low_stress) / SUM(community_centers_high_stress)
                END,
        regexp_replace('Number of community centers accessible by low stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            low stress access to this many community centers.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median community centers access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Median ratio of community centers access',
        quantile(community_centers_ratio,0.5),
        regexp_replace('Ratio of community centers accessible by low stress
            compared to community centers accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of census blocks in this neighborhood
            have low stress access to a higher ratio of community centers within
            biking distance, half have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile community centers access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile ratio of community centers access',
        quantile(community_centers_ratio,0.7),
        regexp_replace('Ratio of community centers accessible by low stress
            compared to community centers accessible by high stress
            expressed as the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of census blocks in this neighborhood
            have low stress access to a higher ratio of community centers within
            biking distance, 70% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 30th percentile community centers access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile ratio of community centers access',
        quantile(community_centers_ratio,0.3),
        regexp_replace('Ratio of community centers accessible by low stress
            compared to community centers accessible by high stress
            expressed as the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of census blocks in this neighborhood
            have low stress access to a higher ratio of community centers within
            biking distance, 30% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- community centers pop shed average low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average community centers bike shed access ratio',
        CASE    WHEN SUM(pop_high_stress) = 0 THEN 0
                ELSE SUM(pop_low_stress)::FLOAT / SUM(pop_high_stress)
                END,
        regexp_replace('Ratio of population with low stress access
            compared to total population within the bike shed distance
            of community centers in the neighborhood expressed as an average of
            all community centers in the neighborhood','\n\s+',' '),
        regexp_replace('On average, community centers in the neighborhood are
            connected by the low stress access to this percentage people
            within biking distance.','\n\s+',' ')
FROM    neighborhood_community_centers
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_community_centers.geom_pt,b.geom)
        );

-- community centers pop shed median low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_comm_ctrs
)
SELECT  'Opportunity',
        'Median community centers population shed ratio',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population with low stress access to community centers
            in the neighborhood to total population within the bike shed
            of each community centers expressed as a median of all
            community centers in the neighborhood','\n\s+',' '),
        regexp_replace('Half of community centers in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, half are connected to a lower percentage.
            (if only one community centers exists this is the score for that one
            location)','\n\s+',' '),
        True
FROM    neighborhood_community_centers
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_community_centers.geom_pt,b.geom)
        );

-- community centers pop shed 70th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile community centers population shed ratio',
        quantile(pop_ratio,0.7),
        regexp_replace('Ratio of population with low stress access to community centers
            in the neighborhood to total population within the bike shed
            of each community centers expressed as the 70th percentile of all
            community centers in the neighborhood','\n\s+',' '),
        regexp_replace('30% of community centers in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 70% are connected to a lower percentage.
            (if only one community centers exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_community_centers
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_community_centers.geom_pt,b.geom)
        );

-- community centers pop shed 30th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile community centers population shed ratio',
        quantile(pop_ratio,0.3),
        regexp_replace('Ratio of population with low stress access to community centers
            in the neighborhood to total population within the bike shed
            of each community centers expressed as the 30th percentile of all
            community centers in the neighborhood','\n\s+',' '),
        regexp_replace('70% of community centers in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 30% are connected to a lower percentage.
            (if only one community centers exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_community_centers
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_community_centers.geom_pt,b.geom)
        );

-------------------------------------
-- transit
-------------------------------------
-- average transit access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average ratio of low stress access to transit',
        CASE    WHEN SUM(transit_high_stress) = 0 THEN 0
                ELSE SUM(transit_low_stress) / SUM(transit_high_stress)
                END,
        regexp_replace('Number of transit stations accessible by low stress
            expressed as an average of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('On average, census blocks in the neighborhood have
            low stress access to this many transit stations.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- median transit access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation, use_transit
)
SELECT  'Opportunity',
        'Median ratio of transit access',
        quantile(transit_ratio,0.5),
        regexp_replace('Ratio of transit stations accessible by low stress
            compared to transit stations accessible by high stress
            expressed as the median of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('Half of census blocks in this neighborhood
            have low stress access to a higher ratio of transit stations within
            biking distance, half have access to a lower ratio.','\n\s+',' '),
        True
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 70th percentile transit access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile ratio of transit access',
        quantile(transit_ratio,0.7),
        regexp_replace('Ratio of transit stations accessible by low stress
            compared to transit stations accessible by high stress
            expressed as the 70th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('30% of census blocks in this neighborhood
            have low stress access to a higher ratio of transit stations within
            biking distance, 70% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- 30th percentile transit access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile ratio of transit access',
        quantile(transit_ratio,0.3),
        regexp_replace('Ratio of transit stations accessible by low stress
            compared to transit stations accessible by high stress
            expressed as the 30th percentile of all census blocks in the
            neighborhood','\n\s+',' '),
        regexp_replace('70% of census blocks in this neighborhood
            have low stress access to a higher ratio of transit stations within
            biking distance, 30% have access to a lower ratio.','\n\s+',' ')
FROM    neighborhood_census_blocks
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_census_blocks.geom,b.geom)
        );

-- transit pop shed average low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Average transit bike shed access ratio',
        CASE    WHEN SUM(pop_high_stress) = 0 THEN 0
                ELSE SUM(pop_low_stress)::FLOAT / SUM(pop_high_stress)
                END,
        regexp_replace('Ratio of population with low stress access
            compared to total population within the bike shed distance
            of transit stations in the neighborhood expressed as an average of
            all transit stations in the neighborhood','\n\s+',' '),
        regexp_replace('On average, transit stations in the neighborhood are
            connected by the low stress access to this percentage people
            within biking distance.','\n\s+',' ')
FROM    neighborhood_transit
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_transit.geom_pt,b.geom)
        );

-- transit pop shed median low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        'Median transit population shed ratio',
        quantile(pop_ratio,0.5),
        regexp_replace('Ratio of population with low stress access to transit stations
            in the neighborhood to total population within the bike shed
            of each transit stations expressed as a median of all
            transit stations in the neighborhood','\n\s+',' '),
        regexp_replace('Half of transit stations in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, half are connected to a lower percentage.
            (if only one transit station exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_transit
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_transit.geom_pt,b.geom)
        );

-- transit pop shed 70th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '70th percentile transit population shed ratio',
        quantile(pop_ratio,0.7),
        regexp_replace('Ratio of population with low stress access to transit stations
            in the neighborhood to total population within the bike shed
            of each transit stations expressed as the 70th percentile of all
            transit stations in the neighborhood','\n\s+',' '),
        regexp_replace('30% of transit stations in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 70% are connected to a lower percentage.
            (if only one transit station exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_transit
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_transit.geom_pt,b.geom)
        );

-- transit pop shed 30th percentile low stress access ratio
INSERT INTO generated.neighborhood_score_inputs (
    category, score_name, score, notes, human_explanation
)
SELECT  'Opportunity',
        '30th percentile transit population shed ratio',
        quantile(pop_ratio,0.3),
        regexp_replace('Ratio of population with low stress access to transit stations
            in the neighborhood to total population within the bike shed
            of each transit stations expressed as the 30th percentile of all
            transit stations in the neighborhood','\n\s+',' '),
        regexp_replace('70% of transit stations in the neighborhood have low stress
            connections to a higher percentage of people within biking
            distance, 30% are connected to a lower percentage.
            (if only one transit station exists this is the score for that one
            location)','\n\s+',' ')
FROM    neighborhood_transit
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(neighborhood_transit.geom_pt,b.geom)
        );
