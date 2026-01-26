-- Add new columns to equipment table
ALTER TABLE equipment 
ADD COLUMN IF NOT EXISTS unit_cost NUMERIC,
ADD COLUMN IF NOT EXISTS equipment_type VARCHAR(20);

-- Backfill equipment_type based on existing data
UPDATE equipment
SET equipment_type = 
  CASE 
    WHEN lease_cost_per_year IS NOT NULL AND lease_cost_per_year > 0 
         AND purchase_cost IS NOT NULL AND purchase_cost > 0 
    THEN 'Both'
    WHEN lease_cost_per_year IS NOT NULL AND lease_cost_per_year > 0 
    THEN 'Lease'
    ELSE 'Purchase'
  END
WHERE equipment_type IS NULL;

-- Backfill unit_cost based on equipment type
UPDATE equipment
SET unit_cost = 
  CASE 
    WHEN lease_cost_per_year IS NOT NULL AND lease_cost_per_year > 0 
         AND lease_term_years IS NOT NULL
    THEN (lease_cost_per_year * lease_term_years) / GREATEST(quantity, 1)
    WHEN purchase_cost IS NOT NULL AND purchase_cost > 0
    THEN purchase_cost / GREATEST(quantity, 1)
    ELSE 0
  END
WHERE unit_cost IS NULL;