-- Add AI system settings
INSERT INTO system_settings (setting_key, setting_value, category, data_type, is_public, description)
VALUES
  ('ai_enabled', '"false"'::jsonb, 'ai', 'boolean', false, 'Master switch to enable/disable AI features'),
  ('ai_provider', '"disabled"'::jsonb, 'ai', 'string', false, 'AI provider: lovable, openai, local, or disabled'),
  ('ai_features', '["insights","recommendations","chat"]'::jsonb, 'ai', 'json', false, 'Enabled AI features')
ON CONFLICT (setting_key) DO NOTHING;