SELECT      r.road_id,
            r.geom,
            COUNT(sheds.node) AS ct
FROM        neighborhood_ways_net_vert v,
            neighborhood_ways r,
            neighborhood_boundary,
            pgr_drivingDistance('
                SELECT  link_id AS id,
                        source_vert AS source,
                        target_vert AS target,
                        link_cost AS cost
                FROM    neighborhood_ways_net_link
                WHERE   link_stress = 1',
                v.vert_id,
                10560,
                directed := true
            ) sheds
WHERE       ST_Intersects(r.geom,neighborhood_boundary.geom)
AND         v.road_id = r.road_id
--and v.road_id = 1467
GROUP BY    r.road_id,
            r.geom;
