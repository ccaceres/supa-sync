-- Drop all existing versions of update_system_setting function
DROP FUNCTION IF EXISTS public.update_system_setting(text, jsonb);
DROP FUNCTION IF EXISTS public.update_system_setting(character varying, jsonb, uuid);

-- Create a single version of the function that handles upsert
CREATE OR REPLACE FUNCTION public.update_system_setting(
  p_setting_key text,
  p_setting_value jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Upsert the setting
  INSERT INTO public.system_settings (setting_key, setting_value, updated_by)
  VALUES (
    p_setting_key,
    p_setting_value,
    auth.uid()
  )
  ON CONFLICT (setting_key)
  DO UPDATE SET
    setting_value = EXCLUDED.setting_value,
    updated_by = auth.uid(),
    updated_at = now();
END;
$$;