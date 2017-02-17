----------------------------------------
-- INPUTS
-- location: neighborhood
-- :nb_boundary_buffer psql var must be set before running this script,
--      e.g. psql -v nb_boundary_buffer=11000 -f reachable_roads_low_stress_calc.sql
----------------------------------------
INSERT INTO generated.neighborhood_reachable_roads_low_stress (
    base_road,
    target_road,
    total_cost
)
SELECT  v1.road_id,
        v2.road_id,
        graph.agg_cost
FROM    neighborhood_ways_net_vert v1,
        neighborhood_ways_net_vert v2,
        neighborhood_ways roads,
        neighborhood_boundary nb,
        pgr_johnson('
            SELECT  links.link_id AS id,
                    links.source_vert AS source,
                    links.target_vert AS target,
                    links.link_cost AS cost
            FROM    neighborhood_ways_net_link links,
                    neighborhood_ways_intersections ints,
                    neighborhood_boundary nb
            WHERE   links.link_stress = 1
            AND     links.int_id = ints.int_id
            AND     ST_DWithin(ints.geom,nb.geom,' || :nb_boundary_buffer || ')',
            directed := true
        ) graph
WHERE   v1.road_id = roads.road_id
AND     ST_Intersects(roads.geom, nb.geom)
AND     graph.start_vid = v1.vert_id
AND     graph.end_vid = v2.vert_id;
