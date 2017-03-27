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
            compared to total population with the bike shed distance
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
            compared to total population with the bike shed distance
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
            compared to total population with the bike shed distance
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
