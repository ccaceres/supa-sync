-- Fix PF_D formula to treat it as a percentage
UPDATE formula_definitions
SET 
  expression = '(UPPH) * (1 - (PF_D / 100)) * CCII',
  updated_at = now()
WHERE formula_key = 'effective_upph' 
  AND model_id = '03ea8f9a-6921-42ba-b432-400e5f682eff';

-- Also fix for any other models that might have this formula
UPDATE formula_definitions
SET 
  expression = '(UPPH) * (1 - (PF_D / 100)) * CCII',
  updated_at = now()
WHERE formula_key = 'effective_upph' 
  AND expression = '(UPPH) * (1 - PF_D) * CCII';