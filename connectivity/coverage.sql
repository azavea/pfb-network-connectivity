SELECT      r.road_id,
            r.geom,
            COUNT(sheds.node) AS ct
FROM        cambridge_ways_net_vert v,
            cambridge_ways r,
            cambridge_boundary,
            pgr_drivingDistance('
                SELECT  link_id AS id,
                        source_vert AS source,
                        target_vert AS target,
                        link_cost AS cost
                FROM    cambridge_ways_net_link
                WHERE   link_stress = 1',
                v.vert_id,
                10560,
                directed := true
            ) sheds
WHERE       ST_Intersects(r.geom,cambridge_boundary.geom)
AND         v.road_id = r.road_id
--and v.road_id = 1467
GROUP BY    r.road_id,
            r.geom;
