-- Fix search_path security issues for all functions
ALTER FUNCTION public.update_capex_row_order() SET search_path = public;
ALTER FUNCTION public.handle_new_user() SET search_path = public;
ALTER FUNCTION public.track_object_link_audit() SET search_path = public;