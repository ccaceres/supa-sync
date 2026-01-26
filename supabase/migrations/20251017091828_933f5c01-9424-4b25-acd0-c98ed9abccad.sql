-- Clear incomplete formula template seed
-- This removes the orphaned metadata row that prevents re-seeding

DELETE FROM formula_templates 
WHERE template_name = 'zulu_standard' 
AND formula_key IS NULL;