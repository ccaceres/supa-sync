-- First, delete duplicate variables keeping only the most recent entry for each key
DELETE FROM formula_variables a
USING formula_variables b
WHERE a.id < b.id 
  AND a.variable_key = b.variable_key 
  AND a.model_id IS NOT DISTINCT FROM b.model_id;

-- Add unique constraint to prevent future duplicates
ALTER TABLE formula_variables
ADD CONSTRAINT formula_variables_unique_key_model 
UNIQUE (variable_key, model_id);