-- Remove equipment_factor and equipment_set_id from equipment table
-- These belong in equipment_set_items only
ALTER TABLE equipment 
DROP COLUMN IF EXISTS equipment_factor,
DROP COLUMN IF EXISTS equipment_set_id;

-- Backfill equipment costs from library_equipment
UPDATE equipment e
SET 
  lease_cost_per_year = COALESCE(e.lease_cost_per_year, le.lease_cost_per_year),
  purchase_cost = COALESCE(e.purchase_cost, le.purchase_cost),
  inflation_rate = COALESCE(e.inflation_rate, le.inflation_rate)
FROM library_equipment le
WHERE e.library_source_id = le.id
  AND (e.lease_cost_per_year IS NULL OR e.purchase_cost IS NULL);