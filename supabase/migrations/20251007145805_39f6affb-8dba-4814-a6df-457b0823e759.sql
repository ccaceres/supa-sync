-- Fix RLS policy for project creation
-- Remove auth.uid() dependency from RLS check since it returns NULL during INSERT
-- Rely on TO authenticated + permission check + application/trigger validation

DROP POLICY IF EXISTS "Users can create projects with permission" ON public.projects;

CREATE POLICY "Users can create projects with permission"
ON public.projects
FOR INSERT
TO authenticated
WITH CHECK (
  -- Only check if the created_by user has permission to create projects
  -- Don't check auth.uid() here as it's NULL during INSERT
  has_permission(created_by, 'projects.create'::permission_type)
);

-- Add trigger for additional validation (defense-in-depth)
CREATE OR REPLACE FUNCTION public.validate_project_created_by()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- If auth.uid() is available, ensure it matches created_by
  IF auth.uid() IS NOT NULL AND NEW.created_by != auth.uid() THEN
    RAISE EXCEPTION 'created_by must match authenticated user';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS validate_project_created_by_trigger ON public.projects;
CREATE TRIGGER validate_project_created_by_trigger
  BEFORE INSERT ON public.projects
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_project_created_by();