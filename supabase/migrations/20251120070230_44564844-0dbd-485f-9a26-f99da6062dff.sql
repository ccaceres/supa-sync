-- Drop the old function if it exists
DROP FUNCTION IF EXISTS update_system_setting(text, jsonb, text);

-- Create improved version that handles updates properly
CREATE OR REPLACE FUNCTION update_system_setting(
  p_setting_key text,
  p_setting_value jsonb,
  p_category text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_existing_setting system_settings%ROWTYPE;
  v_result jsonb;
BEGIN
  -- Check if setting exists
  SELECT * INTO v_existing_setting
  FROM system_settings
  WHERE setting_key = p_setting_key;

  IF FOUND THEN
    -- Setting exists - just update the value
    UPDATE system_settings
    SET 
      setting_value = p_setting_value,
      updated_by = auth.uid(),
      updated_at = now()
    WHERE setting_key = p_setting_key
    RETURNING to_jsonb(system_settings.*) INTO v_result;
    
    RETURN v_result;
  ELSE
    -- Setting doesn't exist - need category to insert
    IF p_category IS NULL THEN
      RAISE EXCEPTION 'Category is required when creating new settings';
    END IF;
    
    INSERT INTO system_settings (
      setting_key,
      setting_value,
      category,
      data_type,
      is_public,
      created_by,
      updated_by
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
    RETURNING to_jsonb(system_settings.*) INTO v_result;
    
    RETURN v_result;
  END IF;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION update_system_setting(text, jsonb, text) TO authenticated;