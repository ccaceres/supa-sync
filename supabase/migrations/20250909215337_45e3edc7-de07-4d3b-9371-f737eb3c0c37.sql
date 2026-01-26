-- Fix security issues from previous migration

-- Drop and recreate the view without SECURITY DEFINER
DROP VIEW IF EXISTS public.customers_secure;

-- Recreate the view as a regular view (not SECURITY DEFINER)
CREATE VIEW public.customers_secure AS
SELECT 
  id,
  name,
  code,
  industry,
  status,
  country,
  contract_type,
  created_at,
  updated_at,
  -- Contact information only visible to admins and managers
  CASE 
    WHEN public.user_can_view_customer_contacts() THEN contact_name 
    ELSE NULL 
  END as contact_name,
  CASE 
    WHEN public.user_can_view_customer_contacts() THEN contact_email 
    ELSE NULL 
  END as contact_email
FROM public.customers;

-- Update the function to have proper search_path (it was already set correctly)
-- The function is already secure, but let's ensure it's properly configured
CREATE OR REPLACE FUNCTION public.user_can_view_customer_contacts()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
  SELECT has_role(auth.uid(), 'admin'::app_role) OR 
         has_role(auth.uid(), 'manager'::app_role)
$$;