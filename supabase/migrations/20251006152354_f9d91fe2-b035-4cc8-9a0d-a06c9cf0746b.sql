-- Add expires_at column to admin_impersonation_sessions table
ALTER TABLE admin_impersonation_sessions 
ADD COLUMN expires_at timestamp with time zone;

-- Backfill existing records with calculated expiration based on duration
UPDATE admin_impersonation_sessions 
SET expires_at = started_at + (session_duration_minutes || ' minutes')::interval
WHERE expires_at IS NULL AND ended_at IS NULL;