-- Fix the corrupted effective_upph formula in the global library
-- This bypasses RLS to correct version 4 -> version 5

UPDATE formula_templates
SET 
  expression = '(UPPH) * (1 - (PF_D / 100)) * CCII',
  version = 5,
  updated_at = now()
WHERE template_name = 'zulu_standard'
  AND formula_key = 'effective_upph';