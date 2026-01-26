-- Fix RLS policy for project creation - check auth.uid() not created_by
DROP POLICY IF EXISTS "Users can create projects with permission" ON public.projects;

CREATE POLICY "Users can create projects with permission"
ON public.projects
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = created_by
  AND has_permission(auth.uid(), 'projects.create'::permission_type)
);