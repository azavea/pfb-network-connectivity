----------------------------------------
-- INPUTS
-- location: neighborhood
-- maximum network distsance: 10560 ft
----------------------------------------
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
WHERE r1.road_id % :thread_num = :thread_no
AND
EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_Intersects(b.geom,r1.geom)
)
AND     r1.road_id = v1.road_id
AND     v2.vert_id = sheds.node;

