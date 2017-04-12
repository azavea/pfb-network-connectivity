----------------------------------------
-- INPUTS
-- location: neighborhood
-- proj: :nb_output_srid psql var must be set before running this script,
--       e.g. psql -v nb_output_srid=2163 -f schools.sql
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_schools;

CREATE TABLE generated.neighborhood_schools (
    id SERIAL PRIMARY KEY,
    blockid10 CHARACTER VARYING(15)[],
    osm_id BIGINT,
    school_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    geom_pt geometry(point, :nb_output_srid),
    geom_poly geometry(polygon, :nb_output_srid)
);

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

-- index
CREATE INDEX sidx_neighborhood_schools_geomply ON neighborhood_schools USING GIST (geom_poly);
ANALYZE generated.neighborhood_schools (geom_poly);

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

-- index
CREATE INDEX sidx_neighborhood_schools_geompt ON neighborhood_schools USING GIST (geom_pt);
ANALYZE generated.neighborhood_schools (geom_pt);

-- set blockid10
UPDATE  generated.neighborhood_schools
SET     blockid10 = array((
            SELECT  cb.blockid10
            FROM    neighborhood_census_blocks cb
            WHERE   ST_Intersects(neighborhood_schools.geom_poly,cb.geom)
            OR      ST_Intersects(neighborhood_schools.geom_pt,cb.geom)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_neighborhood_schools_blockid10 ON neighborhood_schools USING GIN (blockid10);
ANALYZE generated.neighborhood_schools (blockid10);
