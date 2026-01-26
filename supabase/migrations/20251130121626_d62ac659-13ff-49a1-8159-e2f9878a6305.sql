-- Force OpenAI-compatible API endpoint for local LLM
UPDATE system_settings 
SET setting_value = '"openai"'::jsonb
WHERE setting_key = 'ai_local_server_type';