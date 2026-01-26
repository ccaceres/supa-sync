-- Create the validation function for project creation
CREATE OR REPLACE FUNCTION public.validate_project_created_by()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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

-- Create the trigger on projects table
DROP TRIGGER IF EXISTS validate_project_created_by_trigger ON public.projects;
CREATE TRIGGER validate_project_created_by_trigger
BEFORE INSERT ON public.projects
FOR EACH ROW
EXECUTE FUNCTION public.validate_project_created_by();