-- Completely remove RLS restriction on project INSERT for authenticated users
-- The trigger will handle all validation

DROP POLICY IF EXISTS "Users can create projects" ON public.projects;

-- Create a fully permissive policy that just checks authentication
CREATE POLICY "Authenticated users can insert projects"
ON public.projects
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() IS NOT NULL);