-- Add system setting to control Dashboard menu visibility
INSERT INTO system_settings (
  setting_key, 
  setting_value, 
  category, 
  description, 
  data_type, 
  is_public, 
  validation_rules, 
  created_at, 
  updated_at
) VALUES (
  'show_dashboard_menu', 
  'true', 
  'ui', 
  'Show or hide the Dashboard menu option in navigation', 
  'boolean', 
  true,
  '{}',
  NOW(),
  NOW()
);