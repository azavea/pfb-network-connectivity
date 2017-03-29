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
SELECT  'people',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_pop;

-- employment
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'opportunity_employment',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_emp;

-- k12 education
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'opportunity_k12_education',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_k12;

-- tech school
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'opportunity_technical_vocational_college',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_tech;

-- higher ed
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'opportunity_higher_education',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_univ;

-- opportunity
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'opportunity',
        NULL,
        40 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'opportunity_employment')
        + 40 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'opportunity_k12_education')
        + 10 * (select score_original from neighborhood_overall_scores where category = 'opportunity_technical_vocational_college')
        + 10 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'opportunity_higher_education'),
        NULL;

-- doctors
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'core_services_doctors',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_doctor;

-- dentists
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'core_services_dentists',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_dentist;

-- hospitals
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'core_services_hospitals',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_hospital;

-- pharmacies
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'core_services_pharmacies',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_pharmacy;

-- retail
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'core_services_retail',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_retail;

-- grocery
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'core_services_grocery',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_grocery;

-- social services
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'core_services_social_services',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_social_svcs;

-- core services
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'core_services',
        NULL,
        20 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'core_services_doctors')
        + 10 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'core_services_dentists')
        + 20 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'core_services_hospitals')
        + 10 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'core_services_pharmacies')
        + 10 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'core_services_retail')
        + 20 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'core_services_grocery')
        + 10 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'core_services_social_services'),
        NULL;

-- parks
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'recreation_parks',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_parks;

-- trails
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'recreation_trails',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_trails;

-- community_centers
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'recreation_community_centers',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_comm_ctrs;

-- recreation
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'recreation',
        NULL,
        50 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'recreation_parks')
        + 30 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'recreation_trails')
        + 20 * (SELECT score_original FROM neighborhood_overall_scores WHERE category = 'recreation_community_centers'),
        NULL;

-- transit
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'transit',
        COALESCE(neighborhood_score_inputs.score,0),
        100 * COALESCE(neighborhood_score_inputs.score,0),
        neighborhood_score_inputs.human_explanation
FROM    neighborhood_score_inputs
WHERE   use_transit;

-- calculate overall neighborhood score
INSERT INTO generated.neighborhood_overall_scores (
    category, score_original, score_normalized, human_explanation
)
SELECT  'overall_score',
        NULL,
        (
            (SELECT score_normalized FROM neighborhood_overall_scores WHERE category = 'people')
            + (SELECT score_normalized FROM neighborhood_overall_scores WHERE category = 'opportunity')
            + (SELECT score_normalized FROM neighborhood_overall_scores WHERE category = 'core_services')
            + (SELECT score_normalized FROM neighborhood_overall_scores WHERE category = 'recreation')
            + COALESCE((SELECT score_normalized FROM neighborhood_overall_scores WHERE category = 'transit'),0)
        ) / CASE    WHEN (SELECT score_normalized FROM neighborhood_overall_scores WHERE category = 'transit') IS NULL
                        THEN 4
                    ELSE 3
                    END,
        NULL;
