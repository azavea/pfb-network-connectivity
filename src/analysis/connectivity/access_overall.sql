----------------------------------------
-- variables:
--   :total=100
--   :people=20
--   :opportunity=25
--   :core_services=30
--   :recreation=10
--   :transit=15
----------------------------------------
UPDATE  neighborhood_census_blocks
SET     overall_score = :total *
            (
                :people * COALESCE(pop_score,0)
                + :opportunity *
                    CASE
                    WHEN    COALESCE(schools_high_stress,0)
                            + COALESCE(colleges_high_stress,0)
                            + COALESCE(universities_high_stress,0)
                            = 0 THEN 0
                    ELSE    (
                                (
                                    0.35 * COALESCE(emp_score,0)
                                    + 0.35 * COALESCE(schools_score,0)
                                    + 0.1 * COALESCE(colleges_score,0)
                                    + 0.2 * COALESCE(universities_score,0)
                                ) /
                                (
                                    0.35
                                    +   CASE
                                        WHEN schools_high_stress > 0
                                            THEN 0.35
                                        ELSE 0
                                        END
                                    +   CASE
                                        WHEN colleges_high_stress > 0
                                            THEN 0.1
                                        ELSE 0
                                        END
                                    +   CASE
                                        WHEN universities_high_stress > 0
                                            THEN 0.2
                                        ELSE 0
                                        END
                                )
                            )
                    END
                + :core_services *
                    CASE
                    WHEN    COALESCE(doctors_high_stress,0)
                            + COALESCE(dentists_high_stress,0)
                            + COALESCE(hospitals_high_stress,0)
                            + COALESCE(pharmacies_high_stress,0)
                            + COALESCE(supermarkets_high_stress,0)
                            + COALESCE(social_services_high_stress,0)
                            = 0 THEN 0
                    ELSE    (
                                (
                                    0.2 * COALESCE(doctors_score,0)
                                    + 0.1 * COALESCE(dentists_score,0)
                                    + 0.2 * COALESCE(hospitals_score,0)
                                    + 0.1 * COALESCE(pharmacies_score,0)
                                    + 0.25 * COALESCE(supermarkets_score,0)
                                    + 0.15 * COALESCE(social_services_score,0)
                                ) /
                                (
                                    CASE
                                    WHEN doctors_high_stress > 0
                                        THEN 0.2
                                    ELSE 0
                                    END
                                    +   CASE
                                        WHEN dentists_high_stress > 0
                                            THEN 0.1
                                        ELSE 0
                                        END
                                    +   CASE
                                        WHEN hospitals_high_stress > 0
                                            THEN 0.2
                                        ELSE 0
                                        END
                                    +   CASE
                                        WHEN pharmacies_high_stress > 0
                                            THEN 0.1
                                        ELSE 0
                                        END
                                    +   CASE
                                        WHEN supermarkets_high_stress > 0
                                            THEN 0.25
                                        ELSE 0
                                        END
                                    +   CASE
                                        WHEN social_services_high_stress > 0
                                            THEN 0.15
                                        ELSE 0
                                        END
                                )
                            )
                    END
                + :retail * COALESCE(retail_score,0)
                + :recreation *
                    CASE
                    WHEN    COALESCE(parks_high_stress,0)
                            + COALESCE(trails_high_stress,0)
                            + COALESCE(community_centers_high_stress,0)
                            = 0 THEN 0
                    ELSE    (
                                (
                                    0.4 * COALESCE(parks_score,0)
                                    + 0.35 * COALESCE(trails_score,0)
                                    + 0.25 * COALESCE(community_centers_score,0)
                                ) /
                                (
                                    CASE
                                    WHEN parks_high_stress > 0
                                        THEN 0.4
                                    ELSE 0
                                    END
                                    +   CASE
                                        WHEN trails_high_stress > 0
                                            THEN 0.35
                                        ELSE 0
                                        END
                                    +   CASE
                                        WHEN community_centers_high_stress > 0
                                            THEN 0.25
                                        ELSE 0
                                        END
                                )
                            )
                    END
                + :transit * COALESCE(transit_score,0)
            ) /
            (
                :people
                +   CASE
                    WHEN COALESCE(schools_high_stress,0)
                            + COALESCE(colleges_high_stress,0)
                            + COALESCE(universities_high_stress,0)
                            = 0 THEN 0
                    ELSE :opportunity
                    END
                +   CASE
                    WHEN COALESCE(doctors_high_stress,0)
                            + COALESCE(dentists_high_stress,0)
                            + COALESCE(hospitals_high_stress,0)
                            + COALESCE(pharmacies_high_stress,0)
                            + COALESCE(supermarkets_high_stress,0)
                            + COALESCE(social_services_high_stress,0)
                            = 0 THEN 0
                    ELSE :core_services
                    END
                +   CASE
                    WHEN COALESCE(retail_high_stress,0) = 0 THEN 0
                    ELSE :retail
                    END
                +   CASE
                    WHEN COALESCE(parks_high_stress,0)
                            + COALESCE(trails_high_stress,0)
                            + COALESCE(community_centers_high_stress,0)
                            = 0 THEN 0
                    ELSE :recreation
                    END
                +   CASE
                    WHEN COALESCE(transit_high_stress,0) = 0
                        THEN 0
                    ELSE :transit
                    END
            )
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(b.geom,neighborhood_census_blocks.geom)
        );
