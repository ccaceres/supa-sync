-- Insert default project field visibility setting
INSERT INTO system_settings (
  setting_key,
  setting_value,
  category,
  data_type,
  description,
  is_public,
  created_by,
  updated_by
) VALUES (
  'project_visible_fields',
  '["name", "code", "customer_id", "type", "status", "opportunity_value", "start_date", "end_date", "country"]'::jsonb,
  'projects',
  'json',
  'Configure which project fields are visible in project forms',
  false,
  (SELECT auth.uid()),
  (SELECT auth.uid())
)
ON CONFLICT (setting_key) DO NOTHING;