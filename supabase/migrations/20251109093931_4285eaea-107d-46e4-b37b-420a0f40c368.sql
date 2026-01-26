-- Fix equipment cost formula dependencies
-- Remove cumulative_annual_inflation_indirect from depends_on arrays
-- These formulas get CAII from context.calculatedValues, not from evaluating the formula

UPDATE formula_definitions
SET depends_on = ARRAY['equipment_quantity']
WHERE formula_key IN (
  'equipment_lease_cost',
  'equipment_lease_maintenance_cost',
  'equipment_purchase_maintenance_cost'
)
AND (depends_on @> ARRAY['cumulative_annual_inflation_indirect']::text[]);