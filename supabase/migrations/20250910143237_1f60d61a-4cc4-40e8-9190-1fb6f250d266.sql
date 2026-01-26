-- Fix function search path issue by setting it explicitly
-- Removed DROP FUNCTION as CREATE OR REPLACE handles it and DROP fails with dependent triggers

CREATE OR REPLACE FUNCTION public.update_updated_at_pipeline()
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;