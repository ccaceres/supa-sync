-- Drop the overly restrictive policy that blocks project creation
DROP POLICY IF EXISTS "Users can create projects with permission" ON public.projects;

-- Create simplified policy that only checks permission
CREATE POLICY "Users can create projects with permission"
ON public.projects
FOR INSERT
WITH CHECK (
  has_permission(auth.uid(), 'projects.create'::permission_type)
);