----------------------------------------
-- INPUTS
-- location: neighborhood
-- proj: 2249
----------------------------------------
DROP TABLE IF EXISTS neighborhood_streetlight_gates;
CREATE TABLE generated.neighborhood_streetlight_gates (
    id SERIAL PRIMARY KEY,
    geom geometry(polygon,2249),
    road_id BIGINT,
    functional_class TEXT,
    direction INT,
    is_pass INT
);

INSERT INTO neighborhood_streetlight_gates (
    road_id,
    functional_class,
    geom,
    direction,
    is_pass
)
SELECT  road_id,
        functional_class,
        ST_Buffer(
            ST_SetSRID(
                ST_MakeLine(
                    ST_LineInterpolatePoint(geom,0.5),
                    ST_LineInterpolatePoint(geom,0.55)
                ),
                2249
            ),
            100,
            'endcap=flat'
        ) AS geom,
        degrees(ST_Azimuth(
            ST_LineInterpolatePoint(geom,0.5),
            ST_LineInterpolatePoint(geom,0.55)
        )),
        1
FROM    neighborhood_ways
WHERE   functional_class IN ('primary','secondary','tertiary','residential')
AND     EXISTS (
            SELECT  1
            FROM    neighborhood_zip_codes zips
            WHERE   ST_DWithin(neighborhood_ways.geom,zips.geom,11000)
            AND     zips.zip_code = '02138'
        );

-- formatting for upload to SLD
SELECT  road_id AS id,
        road_id AS name,
        is_pass,
        direction,
        geom
FROM    neighborhood_streetlight_gates;
