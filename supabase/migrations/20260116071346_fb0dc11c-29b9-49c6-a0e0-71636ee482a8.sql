-- Drop the overly permissive policy that has qual=true, allowing everyone to see all projects
-- The can_access_project() function already handles ownership check properly
DROP POLICY IF EXISTS "Users can view their own projects" ON public.projects;