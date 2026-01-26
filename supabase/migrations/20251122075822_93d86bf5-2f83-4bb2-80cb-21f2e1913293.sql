-- Fix data_type for boolean settings
UPDATE system_settings 
SET data_type = 'boolean' 
WHERE setting_key IN (
  'adaptive_ip_verification_enabled', 
  'auto_whitelist_verified_ips',
  'ip_restriction_enabled'
) AND data_type != 'boolean';