-- Fix EquipmentFactor variable source from "equipment" to "parameter"
-- This is a data migration to fix the formula variable configuration

-- Update template (global library)
UPDATE formula_templates
SET variables = jsonb_set(
  variables,
  '{1}',
  '{"key": "EquipmentFactor", "source": "parameter", "field": "equipment_factor", "description": "Equipment factor percentage"}'::jsonb
)
WHERE formula_key = 'equipment_quantity';

-- Update all model instances
UPDATE formula_definitions
SET variables = jsonb_set(
  variables,
  '{1}',
  '{"key": "EquipmentFactor", "source": "parameter", "field": "equipment_factor", "description": "Equipment factor percentage"}'::jsonb
)
WHERE formula_key = 'equipment_quantity';