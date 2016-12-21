----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_schools;

CREATE TABLE generated.neighborhood_schools (
    id SERIAL PRIMARY KEY,
    osm_id BIGINT,
    school_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    geom_pt geometry(point,3857),
    geom_poly geometry(polygon,3857)
);
CREATE INDEX sidx_neighborhood_schools_geompt ON neighborhood_schools USING GIST (geom_pt);
CREATE INDEX sidx_neighborhood_schools_geomply ON neighborhood_schools USING GIST (geom_poly);

-- insert points from polygons
INSERT INTO generated.neighborhood_schools (
    osm_id, school_name, geom_pt, geom_poly
)
SELECT  osm_id,
        name,
        ST_Centroid(way),
        way
FROM    neighborhood_osm_full_polygon
WHERE   amenity = 'school';

-- remove subareas that are mistakenly designated as amenity=school
DELETE FROM generated.neighborhood_schools
WHERE   EXISTS (
            SELECT  1
            FROM    generated.neighborhood_schools s
            WHERE   ST_Contains(s.geom_poly,neighborhood_schools.geom_poly)
            AND     s.id != generated.neighborhood_schools.id
);

-- insert points
INSERT INTO generated.neighborhood_schools (
    osm_id, school_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    neighborhood_osm_full_point
WHERE   amenity = 'school'
AND     NOT EXISTS (
            SELECT  1
            FROM    neighborhood_schools s
            WHERE   ST_Intersects(s.geom_poly,neighborhood_osm_full_point.way)
        );
