----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------

CREATE TABLE generated.cambridge_reachable_roads_low_stress (
    id SERIAL PRIMARY KEY,
    base_road INT,
    target_road INT,
    total_cost FLOAT
);

INSERT INTO generated.cambridge_reachable_roads_low_stress (
    base_road,
    target_road,
    total_cost
)
SELECT  r1.road_id,
        v2.road_id,
        sheds.agg_cost
FROM    cambridge_ways r1,
        cambridge_ways_net_vert v1,
        cambridge_ways_net_vert v2,
        pgr_drivingDistance('
            SELECT  link_id AS id,
                    source_vert AS source,
                    target_vert AS target,
                    link_cost AS cost
            FROM    cambridge_ways_net_link
            WHERE   link_stress = 1',
            v1.vert_id,
            10560,
            directed := true
        ) sheds
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_zip_codes zips
            WHERE   ST_Intersects(zips.geom,r1.geom)
            AND     zips.zip_code = '02138'
)
AND     r1.road_id = v1.road_id
AND     v2.vert_id = sheds.node;

CREATE INDEX idx_cambridge_rchblrdslowstrss
ON generated.cambridge_reachable_roads_low_stress (base_road,target_road);
ANALYZE generated.cambridge_reachable_roads_low_stress;
