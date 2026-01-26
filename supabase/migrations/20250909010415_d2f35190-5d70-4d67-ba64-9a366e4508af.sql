-- Fix security warnings by properly securing functions
-- Update the trigger function with proper search_path
CREATE OR REPLACE FUNCTION public.trigger_update_site_allocation()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
    -- Only trigger for non-site-allocation lines
    IF COALESCE(NEW.is_site_allocation, false) = false THEN
        PERFORM update_site_allocation_costs(NEW.model_id);
    END IF;
    RETURN NEW;
END;
$$;