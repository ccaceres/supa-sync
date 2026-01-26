-- Trim whitespace from ai_local_endpoint setting
UPDATE system_settings 
SET setting_value = TRIM(setting_value::text)::jsonb
WHERE setting_key = 'ai_local_endpoint';