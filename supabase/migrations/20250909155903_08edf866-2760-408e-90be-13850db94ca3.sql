-- Fix security warnings by setting search_path for functions

-- Update existing functions to have proper search_path
ALTER FUNCTION public.get_user_roles(UUID) SET search_path = public;
ALTER FUNCTION public.has_role(UUID, app_role) SET search_path = public;  
ALTER FUNCTION public.has_permission(UUID, permission_type) SET search_path = public;
ALTER FUNCTION public.can_access_project(UUID, UUID) SET search_path = public;