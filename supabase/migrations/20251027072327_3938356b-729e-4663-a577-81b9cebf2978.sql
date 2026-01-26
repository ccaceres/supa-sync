-- First, update formula_definitions to reference the correct AWDpHC formula
UPDATE formula_definitions
SET library_formula_id = 'f937006f-7ecd-4f23-bbf0-2c6e0dada31f',
    updated_at = now()
WHERE library_formula_id = '155a9bb8-fb8a-4651-bc08-9fbf819204c6';

-- Now we can safely delete the duplicate formula
DELETE FROM formula_templates 
WHERE formula_key = 'annual_working_days_per_hc';

-- Delete orphaned test formula
DELETE FROM formula_templates 
WHERE formula_key = 'new_formula_1761034527403';

-- Move productivity formulas to headcount category
UPDATE formula_templates 
SET category = 'headcount', updated_at = now()
WHERE formula_key IN (
  'cumulative_ci_impact',
  'daily_volume',
  'effective_upph',
  'shift_1_work_content',
  'shift_2_work_content',
  'shift_3_work_content',
  'total_work_content'
);