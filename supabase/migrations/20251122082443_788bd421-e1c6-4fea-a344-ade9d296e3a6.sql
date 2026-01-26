-- Make adaptive IP verification setting public so it can be read by unauthenticated users
UPDATE system_settings 
SET is_public = true 
WHERE setting_key = 'adaptive_ip_verification_enabled';

-- Also make fail mode public for better error handling
UPDATE system_settings 
SET is_public = true 
WHERE setting_key = 'ip_restriction_fail_mode';