-- Add local LLM configuration settings
INSERT INTO system_settings (setting_key, setting_value, category, data_type, description, is_public)
VALUES 
  ('ai_local_endpoint', '"http://localhost:11434"', 'ai', 'string', 'Local LLM server endpoint (Ollama)', false),
  ('ai_local_model', '"llama3"', 'ai', 'string', 'Local LLM model name', false),
  ('ai_local_api_key', '""', 'ai', 'string', 'Optional API key for secured local LLM deployments', false)
ON CONFLICT (setting_key) DO NOTHING;