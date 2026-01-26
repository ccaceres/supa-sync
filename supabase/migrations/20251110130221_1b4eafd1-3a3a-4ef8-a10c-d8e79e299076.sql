-- Fix missing library links for Google project positions
-- This will enable cost calculations by linking positions to wage data

UPDATE nonexempt_positions
SET library_source_id = 'c839afa3-05e9-4e35-9455-a49854d21c33'
WHERE id = '46d7bdd4-13d4-43f5-9707-6466b73262b8'
AND model_id = '03ea8f9a-6921-42ba-b432-400e5f682eff';

UPDATE nonexempt_positions
SET library_source_id = '0d97e096-29e8-4715-bf24-230bd3a685a1'
WHERE id = '7a829fe9-dafe-49ca-8b2a-0a5c0d150cc1'
AND model_id = '03ea8f9a-6921-42ba-b432-400e5f682eff';