-- Fix search_path for can_edit_project function
CREATE OR REPLACE FUNCTION public.can_edit_project(user_uuid uuid, target_project_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path = 'public'
AS $function$
  SELECT EXISTS (
    -- User is project owner
    SELECT 1 FROM public.projects WHERE id = target_project_id AND created_by = user_uuid
  ) OR EXISTS (
    -- User has write or admin project assignment
    SELECT 1 FROM public.project_assignments 
    WHERE project_id = target_project_id AND user_id = user_uuid 
    AND is_active = true AND access_level IN ('write', 'admin')
  ) OR EXISTS (
    -- User is admin
    SELECT 1 FROM public.user_roles 
    WHERE user_id = user_uuid AND role = 'admin' AND is_active = true
  )
$function$;