-- Add missing ai_local_server_type setting
INSERT INTO system_settings (
  setting_key,
  setting_value,
  category,
  data_type,
  description,
  is_public,
  validation_rules
) VALUES (
  'ai_local_server_type',
  '"auto"'::jsonb,
  'ai',
  'string',
  'Server API type: auto (detect based on model), openai (use /api/chat/completions), or ollama (native Ollama API)',
  false,
  '{}'::jsonb
) ON CONFLICT (setting_key) DO NOTHING;