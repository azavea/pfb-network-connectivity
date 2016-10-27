----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_school_roads;

CREATE TABLE generated.neighborhood_school_roads (
    id SERIAL PRIMARY KEY,
    school_id INT,
    road_id INT
);

-- polygons take any road within 50 feet
INSERT INTO generated.neighborhood_school_roads (
    school_id,
    road_id
)
SELECT  schools.id,
        ways.road_id
FROM    neighborhood_schools schools,
        neighborhood_ways ways
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_DWithin(b.geom, schools.geom_pt, 11000)
        )
AND     schools.geom_poly IS NOT NULL
AND     ST_DWithin(schools.geom_poly,ways.geom,50);

-- points take the nearest road
INSERT INTO generated.neighborhood_school_roads (
    school_id,
    road_id
)
SELECT  schools.id,
        (
            SELECT      ways.road_id
            FROM        neighborhood_ways ways
            ORDER BY    ST_Distance(ways.geom,schools.geom_pt) ASC
            LIMIT       1
        )
FROM    neighborhood_schools schools
WHERE   EXISTS (
            SELECT  1
            FROM    neighborhood_boundary AS b
            WHERE   ST_DWithin(b.geom, schools.geom_pt, 11000)
        )
AND     NOT EXISTS (
            SELECT  1
            FROM    neighborhood_school_roads r
            WHERE   schools.id = r.school_id
        );

CREATE INDEX IF NOT EXISTS idx_neighborhood_schlrds_schlid ON generated.neighborhood_school_roads (school_id);
CREATE INDEX IF NOT EXISTS idx_neighborhood_schlrds_rdid ON generated.neighborhood_school_roads (road_id);
ANALYZE generated.neighborhood_school_roads (school_id, road_id);
