-- Fix equipment cost formulas: Remove formula_reference from Quantity variable
-- This allows Quantity to be read from calculatedValues instead of being re-evaluated

-- Update equipment_lease_cost
UPDATE formula_definitions
SET variables = jsonb_set(
  variables,
  '{0}',
  '{"key": "Quantity", "source": "calculated"}'::jsonb
)
WHERE formula_key = 'equipment_lease_cost'
AND model_id = 'b5f7af51-25de-4aff-918d-d6c43f2a6cce';

-- Update equipment_lease_maintenance_cost  
UPDATE formula_definitions
SET variables = jsonb_set(
  variables,
  '{0}',
  '{"key": "Quantity", "source": "calculated"}'::jsonb
)
WHERE formula_key = 'equipment_lease_maintenance_cost'
AND model_id = 'b5f7af51-25de-4aff-918d-d6c43f2a6cce';

-- Update equipment_purchase_maintenance_cost
UPDATE formula_definitions
SET variables = jsonb_set(
  variables,
  '{0}',
  '{"key": "Quantity", "source": "calculated"}'::jsonb
)
WHERE formula_key = 'equipment_purchase_maintenance_cost'
AND model_id = 'b5f7af51-25de-4aff-918d-d6c43f2a6cce';