-- Create ai_providers table for managing AI provider configurations
CREATE TABLE ai_providers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  provider_type VARCHAR(20) NOT NULL CHECK (provider_type IN ('lovable', 'openai', 'local', 'custom')),
  endpoint VARCHAR(500),
  model VARCHAR(100),
  api_key VARCHAR(500),
  server_type VARCHAR(20) DEFAULT 'auto' CHECK (server_type IN ('auto', 'openai', 'ollama')),
  is_active BOOLEAN DEFAULT true,
  is_default BOOLEAN DEFAULT false,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- Create index for faster lookups
CREATE INDEX idx_ai_providers_active ON ai_providers(is_active) WHERE is_active = true;
CREATE INDEX idx_ai_providers_default ON ai_providers(is_default) WHERE is_default = true;

-- Enable RLS
ALTER TABLE ai_providers ENABLE ROW LEVEL SECURITY;

-- Only admins can manage AI providers
CREATE POLICY "Admins can manage AI providers" ON ai_providers
  FOR ALL 
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Seed default providers
INSERT INTO ai_providers (name, provider_type, description, is_active, is_default) VALUES
  ('Lovable AI', 'lovable', 'Lovable AI Gateway - access to Google Gemini and OpenAI GPT models', true, true),
  ('OpenAI Direct', 'openai', 'Direct OpenAI API access - requires API key in system settings', true, false),
  ('Disabled', 'local', 'AI features disabled', false, false);