-- Fix total_work_content formula to use full variable names instead of shorthands
UPDATE formula_definitions 
SET expression = 'shift_1_work_content + shift_2_work_content + shift_3_work_content',
    updated_at = now()
WHERE model_id = 'ef437758-9a3c-4a3e-b752-f4f757895fc2' 
  AND formula_key = 'total_work_content';