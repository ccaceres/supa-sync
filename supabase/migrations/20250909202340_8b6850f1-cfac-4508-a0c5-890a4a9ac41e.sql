-- Backfill missing MFA settings for existing users
INSERT INTO public.user_mfa_settings (user_id)
SELECT u.id
FROM auth.users u
LEFT JOIN public.user_mfa_settings s ON s.user_id = u.id
WHERE s.user_id IS NULL;

-- Optional: ensure a unique constraint on user_id to support upserts safely
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'user_mfa_settings_user_id_key'
  ) THEN
    ALTER TABLE public.user_mfa_settings
    ADD CONSTRAINT user_mfa_settings_user_id_key UNIQUE (user_id);
  END IF;
END $$;