INSERT INTO system_settings (setting_key, setting_value, category, data_type, description, is_public)
VALUES ('company_video_url', '""', 'ui', 'string', 'URL for the login page background video', true)
ON CONFLICT (setting_key) DO NOTHING;