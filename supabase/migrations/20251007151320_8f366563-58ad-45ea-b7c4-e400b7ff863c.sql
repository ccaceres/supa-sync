-- Fix RLS policy for project creation - remove redundant auth.uid() check
-- The validate_project_created_by() trigger already enforces created_by = auth.uid()
DROP POLICY IF EXISTS "Users can create projects with permission" ON public.projects;

CREATE POLICY "Users can create projects with permission"
ON public.projects
FOR INSERT
TO authenticated
WITH CHECK (
  has_permission(auth.uid(), 'projects.create'::permission_type)
);