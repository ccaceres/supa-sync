-- Remove auth.uid() dependency from RLS INSERT policy
-- Let the trigger handle all validation

DROP POLICY IF EXISTS "Authenticated users can insert projects" ON public.projects;

-- Create a fully permissive policy for authenticated users
-- The validate_project_created_by() trigger will handle security checks
CREATE POLICY "Allow authenticated inserts to reach trigger"
ON public.projects
FOR INSERT
TO authenticated
WITH CHECK (true);