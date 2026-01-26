-- Step 1: Update Global Formula Library (formula_templates)
UPDATE formula_templates
SET 
  expression = 'ROUNDUP(MaxOperatingHeadcountForEquipmentSet * (EquipmentFactor / 100), 0)',
  variables = '[
    {
      "key": "MaxOperatingHeadcountForEquipmentSet",
      "source": "calculated",
      "description": "Sum of operating headcount for tasks using this equipment set"
    },
    {
      "key": "EquipmentFactor",
      "source": "equipment",
      "field": "equipment_factor",
      "description": "Equipment factor percentage (typically 100%)"
    }
  ]'::jsonb,
  description = 'Required equipment quantity based on tasks using this specific equipment set',
  example_calculation = 'Tasks HC for set=2.28, EquipmentFactor=100 → ROUNDUP(2.28 × 1.0, 0) = 3 units',
  tooltip_template = 'Quantity: {MaxOperatingHeadcountForEquipmentSet} HC × {EquipmentFactor}% = {result} units',
  updated_at = now(),
  version = version + 1
WHERE 
  template_name = 'zulu_standard' 
  AND formula_key = 'equipment_quantity';

-- Step 2: Sync All Model Instances (formula_definitions) without incrementing version to keep them in sync
UPDATE formula_definitions
SET 
  variables = '[
    {
      "key": "MaxOperatingHeadcountForEquipmentSet",
      "source": "calculated",
      "description": "Sum of operating headcount for tasks using this equipment set"
    },
    {
      "key": "EquipmentFactor",
      "source": "equipment",
      "field": "equipment_factor",
      "description": "Equipment factor percentage"
    }
  ]'::jsonb,
  description = 'Required equipment quantity based on tasks using this specific equipment set',
  tooltip_template = 'Quantity: {MaxOperatingHeadcountForEquipmentSet} HC × {EquipmentFactor}% = {result} units',
  updated_at = now()
WHERE formula_key = 'equipment_quantity';