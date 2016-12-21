----------------------------------------
-- INPUTS
-- location: neighborhood
-- maximum network distsance: 10560 ft
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_reachable_roads_high_stress;

CREATE TABLE generated.neighborhood_reachable_roads_high_stress (
    id SERIAL PRIMARY KEY,
    base_road INT,
    target_road INT,
    total_cost FLOAT
);

INSERT INTO generated.neighborhood_reachable_roads_high_stress (
    base_road,
    target_road,
    total_cost
)
SELECT  r1.road_id,
        v2.road_id,
        sheds.agg_cost
FROM    neighborhood_ways r1,
        neighborhood_ways_net_vert v1,
        neighborhood_ways_net_vert v2,
        pgr_drivingDistance('
            SELECT  link_id AS id,
                    source_vert AS source,
                    target_vert AS target,
                    link_cost AS cost
            FROM    neighborhood_ways_net_link',
            v1.vert_id,
            10560,
            directed := true
        ) sheds
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_Intersects(zips.geom,r1.geom)
            AND     zips.zip_code = '02138'
)
AND     r1.road_id = v1.road_id
AND     v2.vert_id = sheds.node;

CREATE INDEX idx_neighborhood_rchblrdshistrss_b ON generated.neighborhood_reachable_roads_high_stress (base_road);
CREATE INDEX idx_neighborhood_rchblrdshistrss_t ON generated.neighborhood_reachable_roads_high_stress (target_road);
ANALYZE generated.neighborhood_reachable_roads_high_stress (base_road,target_road);
