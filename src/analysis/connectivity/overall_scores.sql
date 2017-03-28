----------------------------------------
-- INPUTS
-- location: neighborhood
-- Takes the inputs from neighborhood_score_inputs
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
    total_score INTEGER,                -- overall neighborhood connectivity score
    people INTEGER,                     -- category score for people
    opportunity INTEGER,                -- category score for opportunities
    core_services INTEGER,              -- category score for core services
    recreation INTEGER,                 -- category score for recreation
    transit INTEGER,                    -- category score for transit
    opportunity_employment INTEGER,     -- opportunity sub-category score for employment
    opportunity_k12_ed INTEGER,         -- opportunity sub-category score for k-12 schools
    opportunity_tech_school INTEGER,    -- opportunity sub-category score for vocational/tech schools
    opportunity_higher_ed INTEGER,      -- opportunity sub-category score for higher education
    core_svcs_doctor INTEGER,           -- core services sub-category score for doctor offices
    core_svcs_dentist INTEGER,          -- core services sub-category score for dentist offices
    core_svcs_hospital INTEGER,         -- core services sub-category score for hospitals
    core_svcs_pharmacy INTEGER,         -- core services sub-category score for pharmacies
    core_svcs_retail INTEGER,           -- core services sub-category score for retail shopping
    core_svcs_grocery INTEGER,          -- core services sub-category score for grocery stores
    core_svcs_social_svcs INTEGER,      -- core services sub-category score for social services
    recreation_park INTEGER,            -- recreation sub-category score for parks
    recreation_trail INTEGER,           -- recreation sub-category score for trails
    recreation_comm_ctrs INTEGER        -- recreation sub-category score for community centers
);

-- calculate sub-category scores
INSERT INTO generated.neighborhood_overall_scores (
    opportunity_employment, opportunity_k12_ed, opportunity_tech_school, opportunity_higher_ed,
    core_svcs_doctor, core_svcs_dentist, core_svcs_hospital, core_svcs_pharmacy,
    core_svcs_retail, core_svcs_grocery, core_svcs_social_svcs,
    recreation_park, recreation_trail, recreation_comm_ctrs
)
SELECT  100 * (SELECT score FROM neighborhood_score_inputs WHERE use_emp LIMIT 1),
        100 * (SELECT score FROM neighborhood_score_inputs WHERE use_k12 LIMIT 1),
        100 * (SELECT score FROM neighborhood_score_inputs WHERE use_tech LIMIT 1),
        100 * (SELECT score FROM neighborhood_score_inputs WHERE use_univ LIMIT 1),
        100 * (SELECT score FROM neighborhood_score_inputs WHERE use_doctor LIMIT 1),
        100 * (SELECT score FROM neighborhood_score_inputs WHERE use_dentist LIMIT 1),
        100 * (SELECT score FROM neighborhood_score_inputs WHERE use_hospital LIMIT 1),
        100 * (SELECT score FROM neighborhood_score_inputs WHERE use_pharmacy LIMIT 1),
        100 * (SELECT score FROM neighborhood_score_inputs WHERE use_retail LIMIT 1),
        100 * (SELECT score FROM neighborhood_score_inputs WHERE use_grocery LIMIT 1),
        100 * (SELECT score FROM neighborhood_score_inputs WHERE use_social_svcs LIMIT 1),
        100 * (SELECT score FROM neighborhood_score_inputs WHERE use_parks LIMIT 1),
        100 * (SELECT score FROM neighborhood_score_inputs WHERE use_trails LIMIT 1),
        100 * (SELECT score FROM neighborhood_score_inputs WHERE use_comm_ctrs LIMIT 1);


-- calculate main category scores
UPDATE  generated.neighborhood_overall_scores
SET     people = 100 * (SELECT score FROM neighborhood_score_inputs WHERE use_pop LIMIT 1),
        opportunity =   40 * COALESCE(opportunity_employment,0) / 100
                        + 40 * COALESCE(opportunity_k12_ed,0) / 100
                        + 10 * COALESCE(opportunity_tech_school,0) / 100
                        + 10 * COALESCE(opportunity_higher_ed,0) / 100,
        core_services = 20 * COALESCE(core_svcs_doctor,0) / 100
                        + 10 * COALESCE(core_svcs_dentist,0) / 100
                        + 20 * COALESCE(core_svcs_hospital,0) / 100
                        + 10 * COALESCE(core_svcs_pharmacy,0) / 100
                        + 10 * COALESCE(core_svcs_retail,0) / 100
                        + 20 * COALESCE(core_svcs_grocery,0) / 100
                        + 10 * COALESCE(core_svcs_social_svcs,0) / 100,
        recreation =    70 * COALESCE(recreation_park,0) / 100
                        + 30 * COALESCE(recreation_trail,0) / 100,
        transit = 100 * (SELECT score FROM neighborhood_score_inputs WHERE use_transit LIMIT 1);

-- calculate overall neighborhood score
UPDATE  generated.neighborhood_overall_scores
SET     total_score =   (
                            COALESCE(people,0)
                            + COALESCE(opportunity,0)
                            + COALESCE(core_services,0)
                            + COALESCE(recreation,0)
                            + COALESCE(transit,0)
                        )
                        / CASE  WHEN transit IS NULL THEN 4
                                ELSE 5
                                END;
