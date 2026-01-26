-- Make IP restriction settings publicly readable
UPDATE system_settings
SET is_public = true
WHERE setting_key IN ('ip_restriction_enabled', 'allowed_ips');

-- Add RLS policy to allow anonymous users to read public settings
CREATE POLICY "Anonymous users can read public settings"
ON system_settings
FOR SELECT
TO anon
USING (is_public = true);