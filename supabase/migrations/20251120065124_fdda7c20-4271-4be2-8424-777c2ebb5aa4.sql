-- Add IP access control settings to system_settings

-- Enable/disable IP restrictions
INSERT INTO system_settings (
  setting_key,
  setting_value,
  category,
  description,
  data_type,
  is_public
) VALUES (
  'ip_restriction_enabled',
  'false',
  'security',
  'Enable IP-based access control for the application',
  'boolean',
  false
) ON CONFLICT (setting_key) DO NOTHING;

-- Store allowed IPs as JSON array
INSERT INTO system_settings (
  setting_key,
  setting_value,
  category,
  description,
  data_type,
  is_public
) VALUES (
  'allowed_ips',
  '[]',
  'security',
  'List of allowed IP addresses (supports CIDR notation)',
  'json',
  false
) ON CONFLICT (setting_key) DO NOTHING;