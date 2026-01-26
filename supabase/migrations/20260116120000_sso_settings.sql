-- SSO Configuration Settings Migration
-- Adds settings for controlling Microsoft SSO behavior

-- Add SSO configuration settings
INSERT INTO system_settings (setting_key, setting_value, category, description, data_type, is_public)
VALUES
  ('sso_allowed_domains', '["neovialogistics.com"]', 'authentication',
   'Email domains allowed for SSO login (JSON array)', 'json', false),
  ('sso_block_non_domain', 'true', 'authentication',
   'Block SSO login attempts from non-allowed domains', 'boolean', false),
  ('sso_require_activation', 'true', 'authentication',
   'Require administrator activation for new SSO users', 'boolean', false)
ON CONFLICT (setting_key) DO NOTHING;
