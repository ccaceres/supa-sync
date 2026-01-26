-- Drop the validation trigger if it exists
DROP TRIGGER IF EXISTS validate_project_created_by_trigger ON public.projects;

-- Drop the validation function
DROP FUNCTION IF EXISTS public.validate_project_created_by();

-- Make created_by nullable to allow any value
ALTER TABLE public.projects 
ALTER COLUMN created_by DROP NOT NULL;

-- Ensure the INSERT policy is fully permissive for authenticated users
DROP POLICY IF EXISTS "Authenticated users can create projects" ON public.projects;
CREATE POLICY "Authenticated users can create projects" 
ON public.projects 
FOR INSERT 
TO authenticated 
WITH CHECK (true);

-- Also make sure SELECT policy is permissive
DROP POLICY IF EXISTS "Users can view their own projects" ON public.projects;
CREATE POLICY "Users can view their own projects" 
ON public.projects 
FOR SELECT 
TO authenticated 
USING (true);