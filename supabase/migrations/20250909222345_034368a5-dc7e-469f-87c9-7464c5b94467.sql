-- Fix search path issue for the handle_new_user_preferences function
CREATE OR REPLACE FUNCTION public.handle_new_user_preferences()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.user_preferences (user_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$;