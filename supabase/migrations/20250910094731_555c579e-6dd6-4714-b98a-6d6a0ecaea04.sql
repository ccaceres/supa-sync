-- Create can_edit_project function for write access control
CREATE OR REPLACE FUNCTION public.can_edit_project(user_uuid uuid, target_project_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
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

-- Update models table RLS to tighten SELECT policy
DROP POLICY IF EXISTS "Users can view models from accessible projects" ON public.models;
CREATE POLICY "Users can view models from accessible projects" 
ON public.models 
FOR SELECT 
USING (can_access_project(auth.uid(), project_id));

-- Update capex_lines RLS policies
DROP POLICY IF EXISTS "Users can manage capex for accessible models" ON public.capex_lines;
CREATE POLICY "Users can view capex for accessible models" 
ON public.capex_lines 
FOR SELECT 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = capex_lines.model_id 
  AND can_access_project(auth.uid(), m.project_id)
));

CREATE POLICY "Users can edit capex for accessible models" 
ON public.capex_lines 
FOR ALL 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = capex_lines.model_id 
  AND can_edit_project(auth.uid(), m.project_id)
));

-- Update opex_lines RLS policies
DROP POLICY IF EXISTS "Users can manage opex for accessible models" ON public.opex_lines;
CREATE POLICY "Users can view opex for accessible models" 
ON public.opex_lines 
FOR SELECT 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = opex_lines.model_id 
  AND can_access_project(auth.uid(), m.project_id)
));

CREATE POLICY "Users can edit opex for accessible models" 
ON public.opex_lines 
FOR ALL 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = opex_lines.model_id 
  AND can_edit_project(auth.uid(), m.project_id)
));

-- Update impex_lines RLS policies
DROP POLICY IF EXISTS "Users can manage impex for accessible models" ON public.impex_lines;
CREATE POLICY "Users can view impex for accessible models" 
ON public.impex_lines 
FOR SELECT 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = impex_lines.model_id 
  AND can_access_project(auth.uid(), m.project_id)
));

CREATE POLICY "Users can edit impex for accessible models" 
ON public.impex_lines 
FOR ALL 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = impex_lines.model_id 
  AND can_edit_project(auth.uid(), m.project_id)
));

-- Update equipment RLS policies
DROP POLICY IF EXISTS "Users can manage equipment for accessible models" ON public.equipment;
CREATE POLICY "Users can view equipment for accessible models" 
ON public.equipment 
FOR SELECT 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = equipment.model_id 
  AND can_access_project(auth.uid(), m.project_id)
));

CREATE POLICY "Users can edit equipment for accessible models" 
ON public.equipment 
FOR ALL 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = equipment.model_id 
  AND can_edit_project(auth.uid(), m.project_id)
));

-- Update direct_roles RLS policies
DROP POLICY IF EXISTS "Users can manage direct roles for accessible models" ON public.direct_roles;
CREATE POLICY "Users can view direct roles for accessible models" 
ON public.direct_roles 
FOR SELECT 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = direct_roles.model_id 
  AND can_access_project(auth.uid(), m.project_id)
));

CREATE POLICY "Users can edit direct roles for accessible models" 
ON public.direct_roles 
FOR ALL 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = direct_roles.model_id 
  AND can_edit_project(auth.uid(), m.project_id)
));

-- Update salary_roles RLS policies
DROP POLICY IF EXISTS "Users can manage salary roles for accessible models" ON public.salary_roles;
CREATE POLICY "Users can view salary roles for accessible models" 
ON public.salary_roles 
FOR SELECT 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = salary_roles.model_id 
  AND can_access_project(auth.uid(), m.project_id)
));

CREATE POLICY "Users can edit salary roles for accessible models" 
ON public.salary_roles 
FOR ALL 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = salary_roles.model_id 
  AND can_edit_project(auth.uid(), m.project_id)
));

-- Update volumes RLS policies
DROP POLICY IF EXISTS "Users can manage volumes for accessible models" ON public.volumes;
CREATE POLICY "Users can view volumes for accessible models" 
ON public.volumes 
FOR SELECT 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = volumes.model_id 
  AND can_access_project(auth.uid(), m.project_id)
));

CREATE POLICY "Users can edit volumes for accessible models" 
ON public.volumes 
FOR ALL 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = volumes.model_id 
  AND can_edit_project(auth.uid(), m.project_id)
));

-- Update model_parameters RLS policies
DROP POLICY IF EXISTS "Users can manage parameters for accessible models" ON public.model_parameters;
CREATE POLICY "Users can view parameters for accessible models" 
ON public.model_parameters 
FOR SELECT 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = model_parameters.model_id 
  AND can_access_project(auth.uid(), m.project_id)
));

CREATE POLICY "Users can edit parameters for accessible models" 
ON public.model_parameters 
FOR ALL 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = model_parameters.model_id 
  AND can_edit_project(auth.uid(), m.project_id)
));

-- Update opex_price_allocations RLS policies
DROP POLICY IF EXISTS "Users can manage price allocations for accessible models" ON public.opex_price_allocations;
CREATE POLICY "Users can view price allocations for accessible models" 
ON public.opex_price_allocations 
FOR SELECT 
USING (EXISTS (
  SELECT 1 FROM opex_lines ol
  JOIN models m ON ol.model_id = m.id
  WHERE ol.id = opex_price_allocations.opex_line_id 
  AND can_access_project(auth.uid(), m.project_id)
));

CREATE POLICY "Users can edit price allocations for accessible models" 
ON public.opex_price_allocations 
FOR ALL 
USING (EXISTS (
  SELECT 1 FROM opex_lines ol
  JOIN models m ON ol.model_id = m.id
  WHERE ol.id = opex_price_allocations.opex_line_id 
  AND can_edit_project(auth.uid(), m.project_id)
));

-- Update opex_site_allocations RLS policies
DROP POLICY IF EXISTS "Users can manage site allocations for accessible models" ON public.opex_site_allocations;
CREATE POLICY "Users can view site allocations for accessible models" 
ON public.opex_site_allocations 
FOR SELECT 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = opex_site_allocations.model_id 
  AND can_access_project(auth.uid(), m.project_id)
));

CREATE POLICY "Users can edit site allocations for accessible models" 
ON public.opex_site_allocations 
FOR ALL 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = opex_site_allocations.model_id 
  AND can_edit_project(auth.uid(), m.project_id)
));

-- Update library_object_usage RLS policies
DROP POLICY IF EXISTS "Users can manage library usage for accessible models" ON public.library_object_usage;
CREATE POLICY "Users can view library usage for accessible models" 
ON public.library_object_usage 
FOR SELECT 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = library_object_usage.model_id 
  AND can_access_project(auth.uid(), m.project_id)
));

CREATE POLICY "Users can edit library usage for accessible models" 
ON public.library_object_usage 
FOR ALL 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = library_object_usage.model_id 
  AND can_edit_project(auth.uid(), m.project_id)
));

-- Update object_link_audit RLS policies
DROP POLICY IF EXISTS "Users can view audit logs for accessible models" ON public.object_link_audit;
CREATE POLICY "Users can view audit logs for accessible models" 
ON public.object_link_audit 
FOR SELECT 
USING (EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = object_link_audit.model_id 
  AND can_access_project(auth.uid(), m.project_id)
));

-- Update audit_log RLS policies
DROP POLICY IF EXISTS "Users can view audit logs for accessible models" ON public.audit_log;
CREATE POLICY "Users can view audit logs for accessible models" 
ON public.audit_log 
FOR SELECT 
USING ((user_id = auth.uid()) OR EXISTS (
  SELECT 1 FROM models m 
  WHERE m.id = audit_log.model_id 
  AND can_access_project(auth.uid(), m.project_id)
));

-- Update project_assignments RLS policies to allow management
CREATE POLICY "Project editors can manage assignments" 
ON public.project_assignments 
FOR UPDATE 
USING (can_edit_project(auth.uid(), project_id));

CREATE POLICY "Project editors can remove assignments" 
ON public.project_assignments 
FOR DELETE 
USING (can_edit_project(auth.uid(), project_id));