-- Fix library_salary_roles security: restrict access to authenticated users with permissions
-- Current policy allows anyone (true) to read sensitive salary data

-- Drop the overly permissive SELECT policy
DROP POLICY IF EXISTS "Users can view all library salary roles" ON public.library_salary_roles;

-- Create restrictive SELECT policies for salary data
CREATE POLICY "Authenticated users with library view permission can see salary roles"
ON public.library_salary_roles
FOR SELECT
TO authenticated
USING (has_permission(auth.uid(), 'library.view'::permission_type));

-- Also fix library_direct_roles if it has the same issue
DROP POLICY IF EXISTS "Users can view all library direct roles" ON public.library_direct_roles;

CREATE POLICY "Authenticated users with library view permission can see direct roles"
ON public.library_direct_roles
FOR SELECT
TO authenticated
USING (has_permission(auth.uid(), 'library.view'::permission_type));

-- Fix library_equipment as well for consistency
DROP POLICY IF EXISTS "Users can view all library equipment" ON public.library_equipment;

CREATE POLICY "Authenticated users with library view permission can see equipment"
ON public.library_equipment
FOR SELECT
TO authenticated
USING (has_permission(auth.uid(), 'library.view'::permission_type));

-- Fix library_schedules too
DROP POLICY IF EXISTS "Users can view all library schedules" ON public.library_schedules;

CREATE POLICY "Authenticated users with library view permission can see schedules"
ON public.library_schedules
FOR SELECT
TO authenticated
USING (has_permission(auth.uid(), 'library.view'::permission_type));