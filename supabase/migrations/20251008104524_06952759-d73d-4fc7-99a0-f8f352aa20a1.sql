-- Add system setting to control Executive Dashboard visibility in project navigation
INSERT INTO public.system_settings (
  setting_key,
  setting_value,
  category,
  description,
  data_type,
  is_public,
  validation_rules
) VALUES (
  'show_project_executive_dashboard',
  'true'::jsonb,
  'ui',
  'Show Project Executive Dashboard link when a model is selected',
  'boolean',
  true,
  '{}'::jsonb
) ON CONFLICT (setting_key) DO NOTHING;