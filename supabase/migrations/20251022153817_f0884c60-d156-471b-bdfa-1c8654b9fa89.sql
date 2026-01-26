-- Update all existing records with null year_column_style to use default styling
UPDATE spreadsheet_view_preferences 
SET year_column_style = '{"pattern": "pair", "intensity": "medium"}'::jsonb
WHERE year_column_style IS NULL;

-- Set default value for new records
ALTER TABLE spreadsheet_view_preferences 
ALTER COLUMN year_column_style SET DEFAULT '{"pattern": "pair", "intensity": "medium"}'::jsonb;