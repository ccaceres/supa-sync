-- Clean up duplicate formulas and add unique constraint

-- Step 1: Delete duplicate formulas, keeping only the most recent one per (formula_key, model_id)
DELETE FROM formula_definitions
WHERE id NOT IN (
  SELECT DISTINCT ON (formula_key, model_id) id
  FROM formula_definitions
  ORDER BY formula_key, model_id, created_at DESC
);

-- Step 2: Add unique constraint to prevent future duplicates
-- This ensures each formula_key can only appear once per model
ALTER TABLE formula_definitions
ADD CONSTRAINT unique_formula_key_per_model UNIQUE (formula_key, model_id);