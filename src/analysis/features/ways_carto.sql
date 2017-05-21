----------------------------------------
-- Creates a table of segmented geometries
-- based on neighborhood_ways. Used for
-- showing segment and intersection stress
-- in mapping.
--
-- Variables:
--      :nb_output_srid -> SRID of the analysis
--      :min_length -> Minimum length, below which lines are split based on percentages
--      :int_length -> Length of line to reserve for intersection stress
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_ways_carto;
CREATE TABLE generated.neighborhood_ways_carto (
    id SERIAL PRIMARY KEY,
    parent_tdg_id TEXT,
    parent_position TEXT,
    geom geometry(linestring,:nb_output_srid),
    ft_stress INTEGER,
    tf_stress INTEGER
);

-- segment
INSERT INTO generated.neighborhood_ways_carto (
    parent_tdg_id, parent_position, geom, ft_stress, tf_stress
)
SELECT  tdg_id,
        'segment',
        CASE
        WHEN ST_Length(geom) < :min_length
            THEN ST_LineSubstring(geom,0.15,0.85)
        ELSE ST_LineSubstring(
            geom,
            20 / ST_Length(geom),
            1 - 20 / ST_Length(geom)
        )
        END,
        CASE WHEN COALESCE(one_way,'ft') = 'ft' THEN ft_seg_stress ELSE NULL END,
        CASE WHEN COALESCE(one_way,'tf') = 'tf' THEN tf_seg_stress ELSE NULL END
FROM    neighborhood_ways;

-- to intersection
INSERT INTO generated.neighborhood_ways_carto (
    parent_tdg_id, parent_position, geom, ft_stress, tf_stress
)
SELECT  tdg_id,
        'segment',
        CASE
        WHEN ST_Length(geom) < :min_length
            THEN ST_LineSubstring(geom,0.85,1)
        ELSE ST_LineSubstring(
            geom,
            1 - :int_length / ST_Length(geom),
            1
        )
        END,
        CASE WHEN COALESCE(one_way,'ft') = 'ft' THEN GREATEST(ft_int_stress, ft_seg_stress) ELSE NULL END,
        CASE WHEN COALESCE(one_way,'tf') = 'tf' THEN tf_seg_stress ELSE NULL END
FROM    neighborhood_ways;

-- from intersection
INSERT INTO generated.neighborhood_ways_carto (
    parent_tdg_id, parent_position, geom, ft_stress, tf_stress
)
SELECT  tdg_id,
        'segment',
        CASE
        WHEN ST_Length(geom) < :min_length
            THEN ST_LineSubstring(geom,0,0.15)
        ELSE ST_LineSubstring(
            geom,
            0,
            :int_length / ST_Length(geom)
        )
        END,
        CASE WHEN COALESCE(one_way,'ft') = 'ft' THEN ft_seg_stress ELSE NULL END,
        CASE WHEN COALESCE(one_way,'tf') = 'tf' THEN GREATEST(tf_int_stress, tf_seg_stress) ELSE NULL END
FROM    neighborhood_ways;
