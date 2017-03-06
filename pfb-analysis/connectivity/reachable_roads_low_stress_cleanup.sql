----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
CREATE INDEX IF NOT EXISTS idx_neighborhood_rchblrdslowstrss_b ON generated.neighborhood_reachable_roads_low_stress (base_road);
CREATE INDEX IF NOT EXISTS idx_neighborhood_rchblrdslowstrss_t ON generated.neighborhood_reachable_roads_low_stress (target_road);
VACUUM ANALYZE generated.neighborhood_reachable_roads_low_stress (base_road,target_road);
