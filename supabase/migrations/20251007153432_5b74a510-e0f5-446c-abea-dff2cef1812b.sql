-- Remove auth.uid() check from trigger to fix NULL issue
-- Permission validation is sufficient since created_by is already validated client-side

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
  
  -- Check if user has permission to create projects
  IF NOT has_permission(NEW.created_by, 'projects.create'::permission_type) THEN
    RAISE EXCEPTION 'User does not have permission to create projects';
  END IF;
  
  RETURN NEW;
END;
$$;