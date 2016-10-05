----------------------------------------
-- INPUTS
-- location: cambridge
----------------------------------------
DROP TABLE IF EXISTS generated.cambridge_schools;

CREATE TABLE generated.cambridge_schools (
    id SERIAL PRIMARY KEY,
    osm_id BIGINT,
    school_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    geom_pt geometry(point,2249),
    geom_poly geometry(polygon,2249)
);
CREATE INDEX sidx_cambridge_schools_geompt ON cambridge_schools USING GIST (geom_pt);
CREATE INDEX sidx_cambridge_schools_geomply ON cambridge_schools USING GIST (geom_poly);

-- insert points from polygons
INSERT INTO generated.cambridge_schools (
    osm_id, school_name, geom_pt, geom_poly
)
SELECT  osm_id,
        name,
        ST_Centroid(way),
        way
FROM    cambridge_osm_full_polygon
WHERE   amenity = 'school';

-- remove subareas that are mistakenly designated as amenity=school
DELETE FROM generated.cambridge_schools
WHERE   EXISTS (
            SELECT  1
            FROM    generated.cambridge_schools s
            WHERE   ST_Contains(s.geom_poly,cambridge_schools.geom_poly)
            AND     s.id != generated.cambridge_schools.id
);

-- insert points
INSERT INTO generated.cambridge_schools (
    osm_id, school_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    cambridge_osm_full_point
WHERE   amenity = 'school'
AND     NOT EXISTS (
            SELECT  1
            FROM    cambridge_schools s
            WHERE   ST_Intersects(s.geom_poly,cambridge_osm_full_point.way)
        );
