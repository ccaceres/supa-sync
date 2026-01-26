-- Add IP 185.238.141.130 to the allowed IPs list
UPDATE system_settings
SET setting_value = '["217.122.218.155", "192.86.106.33", "185.238.141.130"]'::jsonb,
    updated_at = now()
WHERE setting_key = 'allowed_ips';

-- Verify the update
SELECT setting_key, setting_value 
FROM system_settings 
WHERE setting_key = 'allowed_ips';