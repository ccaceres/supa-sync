-- Add Year variable for equipment formulas
INSERT INTO formula_variables (
  variable_key,
  display_name,
  source_type,
  source_field,
  data_type,
  category,
  description,
  is_system,
  model_id
) VALUES (
  'Year',
  'Year',
  'calculated_field',
  NULL,
  'number',
  'equipment',
  'The year number for equipment cost calculations',
  true,
  NULL
)
ON CONFLICT (variable_key, model_id) DO UPDATE SET
  source_type = EXCLUDED.source_type,
  description = EXCLUDED.description,
  category = EXCLUDED.category;

-- Add equipment-specific Quantity variable (calculated from equipment_quantity formula)
INSERT INTO formula_variables (
  variable_key,
  display_name,
  source_type,
  source_field,
  data_type,
  category,
  description,
  formula_reference,
  is_system,
  model_id
) VALUES (
  'Quantity',
  'Equipment Quantity',
  'calculated_field',
  NULL,
  'number',
  'equipment',
  'Equipment quantity calculated by equipment_quantity formula and provided in calculatedValues',
  'equipment_quantity',
  true,
  NULL
)
ON CONFLICT (variable_key, model_id) DO UPDATE SET
  source_type = EXCLUDED.source_type,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  formula_reference = EXCLUDED.formula_reference;