-- Add system settings for Round field visibility
INSERT INTO system_settings (setting_key, setting_value, data_type, category, description, is_public)
VALUES 
  ('round_visible_fields', 
   '["round_number", "name", "status", "type", "kickoff_date", "submission_date", "pipeline_id", "approver_designations"]',
   'json',
   'rounds',
   'Controls which fields are visible in the round creation wizard',
   true),
  ('round_visible_wizard_steps',
   '[1, 2, 3, 4, 5]',
   'json',
   'rounds',
   'Controls which wizard steps are visible during round creation',
   true)
ON CONFLICT (setting_key) DO NOTHING;