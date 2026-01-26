-- Fix category casing for project configuration settings
UPDATE system_settings 
SET category = 'projects' 
WHERE setting_key IN ('project_categories', 'project_types', 'round_type_suggestions')
  AND category = 'Projects';