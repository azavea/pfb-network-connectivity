----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
DROP TABLE IF EXISTS generated.cambridge_school_roads;

CREATE TABLE generated.cambridge_school_roads (
    id SERIAL PRIMARY KEY,
    school_id INT,
    road_id INT
);

-- polygons take any road within 50 feet
INSERT INTO generated.cambridge_school_roads (
    school_id,
    road_id
)
SELECT  schools.id,
        ways.road_id
FROM    cambridge_schools schools,
        cambridge_ways ways
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_zip_codes zips
            WHERE   ST_DWithin(zips.geom, schools.geom_pt, 11000)
            AND     zips.zip_code = '02138'
        )
AND     schools.geom_poly IS NOT NULL
AND     ST_DWithin(schools.geom_poly,ways.geom,50);

-- points take the nearest road
INSERT INTO generated.cambridge_school_roads (
    school_id,
    road_id
)
SELECT  schools.id,
        (
            SELECT      ways.road_id
            FROM        cambridge_ways ways
            ORDER BY    ST_Distance(ways.geom,schools.geom_pt) ASC
            LIMIT       1
        )
FROM    cambridge_schools schools
WHERE   EXISTS (
            SELECT  1
            FROM    cambridge_zip_codes zips
            WHERE   ST_DWithin(zips.geom, schools.geom_pt, 11000)
            AND     zips.zip_code = '02138'
        )
AND     NOT EXISTS (
            SELECT  1
            FROM    cambridge_school_roads r
            WHERE   schools.id = r.school_id
        );

CREATE INDEX idx_cambridge_schlrds_schlid ON generated.cambridge_school_roads (school_id);
CREATE INDEX idx_cambridge_schlrds_rdid ON generated.cambridge_school_roads (road_id);
ANALYZE generated.cambridge_school_roads (school_id, road_id);
