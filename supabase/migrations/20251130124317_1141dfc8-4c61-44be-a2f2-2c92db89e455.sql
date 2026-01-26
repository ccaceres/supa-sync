-- Fix leading space in ai_local_endpoint by properly handling JSONB string
UPDATE system_settings 
SET setting_value = to_jsonb(trim(setting_value::text, '" '))
WHERE setting_key = 'ai_local_endpoint';