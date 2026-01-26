-- Fix function search path security issue
CREATE OR REPLACE FUNCTION ensure_single_default_pipeline()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- If setting this pipeline as default, unset all others
  IF NEW.is_default = true AND NEW.is_active = true THEN
    UPDATE approval_pipelines 
    SET is_default = false 
    WHERE id != NEW.id 
      AND is_default = true 
      AND is_active = true;
  END IF;
  
  RETURN NEW;
END;
$$;