-- Fix Security Definer View issue by removing unused view
-- The application already handles customer contact security at the application layer

-- Drop the problematic customers_secure view that's not being used
DROP VIEW IF EXISTS public.customers_secure;

-- The user_can_view_customer_contacts function can also be dropped since it's only used by the view
DROP FUNCTION IF EXISTS public.user_can_view_customer_contacts();