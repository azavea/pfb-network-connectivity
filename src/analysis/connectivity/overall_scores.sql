----------------------------------------
-- INPUTS
-- location: neighborhood
-- Takes the inputs from neighborhood_neighborhood_score_inputs
--   and converts to scores for each of the
--   subcategories. Then, combines the
--   subcategory scores into an overall category
--   score. Finally, combines category scores into
--   a single master score for the entire
--   neighborhood.
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_overall_scores;

CREATE TABLE generated.neighborhood_overall_scores (
    id SERIAL PRIMARY KEY,
    category TEXT,
    score_original NUMERIC(16,4),
    score_normalized INTEGER,
    human_explanation TEXT
);

-- population
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'People',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_pop;

-- employment
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Opportunity:Employment',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_emp;

-- k12 education
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Opportunity:K12 Education',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_k12;

-- tech school
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Opportunity:Technical/Vocational College',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_tech;

-- higher ed
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Opportunity:Higher Education',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_univ;

-- opportunity
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Opportunity',
        NULL,
        40 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'Opportunity:Employment')
        + 40 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'Opportunity:K12 Education')
        + 10 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'Opportunity:Technical/Vocational College')
        + 10 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'Opportunity:Higher Education'),
        NULL;

-- doctors
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Core Services:Doctors',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_doctor;

-- dentists
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Core Services:Dentists',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_dentist;

-- hospitals
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Core Services:Hospitals',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_hospital;

-- pharmacies
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Core Services:Pharmacies',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_pharmacy;

-- retail
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Core Services:Retail',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_retail;

-- grocery
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Core Services:Grocery',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_grocery;

-- social services
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Core Services:Social Services',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_social_svcs;

-- core services
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Core Services',
        NULL,
        20 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'Core Services:Doctors')
        + 10 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'Core Services:Dentists')
        + 20 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'Core Services:Hospitals')
        + 10 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'Core Services:Pharmacies')
        + 10 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'Core Services:Retail')
        + 20 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'Core Services:Grocery')
        + 10 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'Core Services:Social Services'),
        NULL;

-- parks
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Recreation:Parks',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_parks;

-- trails
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Recreation:Trails',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_trails;

-- community_centers
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Recreation:Community Centers',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_comm_ctrs;

-- recreation
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Recreation',
        NULL,
        50 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'Recreation:Parks')
        + 30 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'Recreation:Trails')
        + 20 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'Recreation:Community Centers'),
        NULL;

-- transit
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Transit',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_transit;

-- calculate overall neighborhood score
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'Overall Score',
        NULL,
        (
            (SELECT score_normalized FROM neighborhood_overall_scores WHERE category = 'People')
            + (SELECT score_normalized FROM neighborhood_overall_scores WHERE category = 'Opportunity')
            + (SELECT score_normalized FROM neighborhood_overall_scores WHERE category = 'Core Services')
            + (SELECT score_normalized FROM neighborhood_overall_scores WHERE category = 'Recreation')
            + COALESCE((SELECT score_normalized FROM neighborhood_overall_scores WHERE category = 'Transit'),0)
        ) / CASE    WHEN (SELECT score_normalized FROM neighborhood_overall_scores WHERE category = 'Transit') IS NULL
                        THEN 4
                    ELSE 3
                    END,
        NULL;
