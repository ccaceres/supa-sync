-- Fix EquipmentFactor source in existing formula definitions
-- This ensures all models use the correct parameter source for EquipmentFactor

UPDATE formula_definitions
SET variables = jsonb_set(
  variables,
  '{1}',
  jsonb_build_object(
    'key', 'EquipmentFactor',
    'source', 'parameter',
    'field', 'equipment_factor'
  )
)
WHERE formula_key = 'equipment_quantity'
  AND variables @> '[{"key": "EquipmentFactor"}]'::jsonb
  AND variables #>> '{1,source}' = 'equipment';

-- Add comment explaining the fix
COMMENT ON TABLE formula_definitions IS 'Equipment quantity formulas now correctly read EquipmentFactor from parameters (LABEX-weighted) instead of equipment table';