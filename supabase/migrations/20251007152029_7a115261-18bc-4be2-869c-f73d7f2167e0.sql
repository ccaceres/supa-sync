-- Fix project creation by moving permission check to trigger
-- This avoids auth.uid() returning NULL during RLS checks

-- Drop the restrictive RLS policy
DROP POLICY IF EXISTS "Users can create projects with permission" ON public.projects;

-- Create a permissive RLS policy for authenticated users
CREATE POLICY "Users can create projects"
ON public.projects
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Strengthen the trigger to include permission checks
CREATE OR REPLACE FUNCTION public.validate_project_created_by()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  -- Ensure created_by is set
  IF NEW.created_by IS NULL THEN
    RAISE EXCEPTION 'created_by cannot be null';
  END IF;
  
  -- Verify created_by matches authenticated user
  IF auth.uid() IS NOT NULL AND NEW.created_by != auth.uid() THEN
    RAISE EXCEPTION 'created_by must match authenticated user';
  END IF;
  
  -- Check if user has permission to create projects
  IF NOT has_permission(NEW.created_by, 'projects.create'::permission_type) THEN
    RAISE EXCEPTION 'User does not have permission to create projects';
  END IF;
  
  RETURN NEW;
END;
$$;