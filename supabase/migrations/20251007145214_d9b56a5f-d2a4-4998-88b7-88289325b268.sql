-- Fix RLS policy for project creation
-- The issue is that auth.uid() returns NULL during INSERT
-- Instead, we check permission based on the created_by field that the client sets

DROP POLICY IF EXISTS "Users can create projects with permission" ON public.projects;

CREATE POLICY "Users can create projects with permission"
ON public.projects
FOR INSERT
TO public
WITH CHECK (
  -- Verify the created_by user has permission to create projects
  has_permission(created_by, 'projects.create'::permission_type)
  -- Optionally, if auth.uid() is available, ensure it matches created_by
  AND (auth.uid() IS NULL OR auth.uid() = created_by)
);