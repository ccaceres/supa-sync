-- Add ai_provider_id setting to system_settings table
INSERT INTO system_settings (category, setting_key, setting_value, data_type, description, is_public)
VALUES ('ai', 'ai_provider_id', '""', 'string', 'Selected AI provider UUID from ai_providers table', false)
ON CONFLICT (setting_key) DO NOTHING;