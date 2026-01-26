-- Add system settings for project configuration with default values

-- Insert project categories
INSERT INTO public.system_settings (setting_key, category, description, data_type, setting_value, is_public, validation_rules)
VALUES (
  'project_categories',
  'Projects',
  'Available project categories for classification',
  'json',
  '[
    {"name": "New Business", "description": "New client acquisition projects", "is_active": true},
    {"name": "Existing Business", "description": "Projects for current clients", "is_active": true},
    {"name": "Consultative", "description": "Advisory and consulting projects", "is_active": true}
  ]'::jsonb,
  true,
  '{"type": "array"}'::jsonb
) ON CONFLICT (setting_key) DO NOTHING;

-- Insert project types mapped to categories
INSERT INTO public.system_settings (setting_key, category, description, data_type, setting_value, is_public, validation_rules)
VALUES (
  'project_types',
  'Projects',
  'Available project types organized by category',
  'json',
  '{
    "New Business": [
      {"name": "RFP Response", "description": "Response to Request for Proposal", "is_active": true},
      {"name": "Non-Competitive", "description": "Direct award projects", "is_active": true}
    ],
    "Existing Business": [
      {"name": "Incremental Scope", "description": "Additional scope for existing client", "is_active": true},
      {"name": "Renewal", "description": "Contract renewal", "is_active": true},
      {"name": "Reprice", "description": "Pricing adjustment", "is_active": true}
    ],
    "Consultative": [
      {"name": "Network Design", "description": "Network planning and design", "is_active": true},
      {"name": "ROM", "description": "Rough Order of Magnitude estimate", "is_active": true},
      {"name": "CI/Implementation Assistance", "description": "Continuous improvement support", "is_active": true}
    ]
  }'::jsonb,
  true,
  '{"type": "object"}'::jsonb
) ON CONFLICT (setting_key) DO NOTHING;

-- Insert round type suggestions mapped to project types
INSERT INTO public.system_settings (setting_key, category, description, data_type, setting_value, is_public, validation_rules)
VALUES (
  'round_type_suggestions',
  'Projects',
  'Suggested round types for each project type',
  'json',
  '{
    "RFP Response": "Competitive Round",
    "Non-Competitive": "Partnership Round",
    "Incremental Scope": "Scope Extension Round",
    "Renewal": "Scope Extension Round",
    "Reprice": "Rate Adjustment Round",
    "Network Design": "Advisory Round",
    "ROM": "Advisory Round",
    "CI/Implementation Assistance": "Advisory Round"
  }'::jsonb,
  true,
  '{"type": "object"}'::jsonb
) ON CONFLICT (setting_key) DO NOTHING;