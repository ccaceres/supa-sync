-- Create or replace function to update/insert system settings
CREATE OR REPLACE FUNCTION public.update_system_setting(
  p_setting_key TEXT,
  p_setting_value JSONB
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Upsert the system setting
  INSERT INTO system_settings (
    setting_key,
    setting_value,
    updated_at,
    updated_by
  ) VALUES (
    p_setting_key,
    p_setting_value,
    NOW(),
    auth.uid()
  )
  ON CONFLICT (setting_key)
  DO UPDATE SET
    setting_value = EXCLUDED.setting_value,
    updated_at = NOW(),
    updated_by = auth.uid()
  RETURNING jsonb_build_object(
    'id', id,
    'setting_key', setting_key,
    'setting_value', setting_value,
    'updated_at', updated_at
  );
END;
$$;