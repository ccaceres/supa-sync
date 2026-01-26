-- Backfill missing purchase costs from library_equipment to equipment
UPDATE equipment e
SET 
  purchase_cost = COALESCE(e.purchase_cost, le.purchase_cost),
  lease_cost_per_year = COALESCE(e.lease_cost_per_year, le.lease_cost_per_year),
  inflation_rate = COALESCE(e.inflation_rate, le.inflation_rate)
FROM library_equipment le
WHERE e.library_source_id = le.id
  AND (e.purchase_cost IS NULL OR e.lease_cost_per_year IS NULL OR e.inflation_rate IS NULL);