-- Remove broken model-specific IMPEX formulas that conflict with global definitions
-- The model-specific formulas have outdated variable definitions that cause calculation failures

DELETE FROM formula_definitions 
WHERE formula_key IN ('impex_yearly_cost', 'impex_base_cost', 'impex_final_cost')
  AND model_id = 'b5f7af51-25de-4aff-918d-d6c43f2a6cce'
  AND is_active = true;

-- Log the cleanup
DO $$
BEGIN
  RAISE NOTICE 'Removed model-specific IMPEX formulas to allow global formulas to be used';
END $$;