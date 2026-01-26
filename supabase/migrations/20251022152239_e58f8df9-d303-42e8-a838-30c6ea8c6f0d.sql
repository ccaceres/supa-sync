-- Add year_column_style column to spreadsheet_view_preferences table
ALTER TABLE spreadsheet_view_preferences 
ADD COLUMN IF NOT EXISTS year_column_style JSONB DEFAULT NULL;

COMMENT ON COLUMN spreadsheet_view_preferences.year_column_style IS 'Year column styling configuration (pattern, intensity)';