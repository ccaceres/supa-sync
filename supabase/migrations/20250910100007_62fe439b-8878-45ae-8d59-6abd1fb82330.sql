-- Restrict project visibility to only owners, assigned users, or admins via can_access_project
BEGIN;

-- Ensure RLS is enabled (safe no-op if already enabled)
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

-- Drop the broad SELECT policy that allowed global view permission
DROP POLICY IF EXISTS "Users can view projects with permission" ON public.projects;

-- Create a stricter SELECT policy relying solely on access checks
CREATE POLICY "Users can view accessible projects"
ON public.projects
FOR SELECT
USING (public.can_access_project(auth.uid(), id));

COMMIT;