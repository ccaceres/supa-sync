-- Drop the existing function
DROP FUNCTION IF EXISTS public.update_system_setting(text, jsonb);

-- Create the function with proper handling of all required fields
CREATE OR REPLACE FUNCTION public.update_system_setting(
  p_setting_key text,
  p_setting_value jsonb,
  p_category text DEFAULT 'parameters'
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  -- Upsert the setting with all required fields
  INSERT INTO public.system_settings (
    setting_key,
    setting_value,
    category,
    data_type,
    is_public,
    updated_by,
    created_by
  )
  VALUES (
    p_setting_key,
    p_setting_value,
    p_category,
    'json',
    false,
    auth.uid(),
    auth.uid()
  )
  ON CONFLICT (setting_key)
  DO UPDATE SET
    setting_value = EXCLUDED.setting_value,
    updated_by = auth.uid(),
    updated_at = now();
END;
$$;