-- Extract and seed all unique variables from formula templates into formula_variables table
-- This ensures all referenced symbols in formulas are properly defined as system variables

-- First, create a temp table with all variables to insert
WITH template_vars AS (
  SELECT DISTINCT
    NULL::uuid as model_id,
    (var->>'key')::text as variable_key,
    (var->>'key')::text as display_name,
    CASE 
      WHEN var->>'source' = 'calculated' THEN 'calculated_field'
      ELSE 'data_field'
    END as source_type,
    CASE 
      WHEN var->>'source' = 'task' THEN 'dl_roles'
      WHEN var->>'source' = 'position' THEN 'nonexempt_positions'
      WHEN var->>'source' = 'schedule' THEN 'ci_schedules'
      WHEN var->>'source' = 'parameter' THEN 'model_parameters'
      ELSE NULL
    END as source_table,
    (var->>'field')::text as source_field,
    (var->>'formula_reference')::text as formula_reference,
    true as is_system,
    CASE 
      WHEN var->>'source' IS NOT NULL THEN 
        'Auto-extracted from formula template: ' || (var->>'source')::text || 
        CASE WHEN var->>'field' IS NOT NULL THEN ' → ' || (var->>'field')::text ELSE '' END
      ELSE 'Auto-extracted from formula templates'
    END as description,
    CASE 
      WHEN var->>'source' = 'task' THEN 'Task Fields'
      WHEN var->>'source' = 'position' THEN 'Position Fields'
      WHEN var->>'source' = 'schedule' THEN 'Schedule Fields'
      WHEN var->>'source' = 'parameter' THEN 'Parameters'
      WHEN var->>'source' = 'calculated' THEN 'Calculated'
      ELSE 'Other'
    END as category
  FROM formula_templates ft,
       jsonb_array_elements(ft.variables) as var
  WHERE var->>'key' IS NOT NULL
)
INSERT INTO formula_variables (
  model_id,
  variable_key,
  display_name,
  source_type,
  source_table,
  source_field,
  formula_reference,
  is_system,
  description,
  category
)
SELECT 
  tv.model_id,
  tv.variable_key,
  tv.display_name,
  tv.source_type,
  tv.source_table,
  tv.source_field,
  tv.formula_reference,
  tv.is_system,
  tv.description,
  tv.category
FROM template_vars tv
WHERE NOT EXISTS (
  SELECT 1 FROM formula_variables fv 
  WHERE fv.variable_key = tv.variable_key 
    AND fv.is_system = true
    AND fv.model_id IS NULL
);