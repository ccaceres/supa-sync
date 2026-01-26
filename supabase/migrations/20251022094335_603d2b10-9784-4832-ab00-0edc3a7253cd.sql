-- Fix RLS policy for dl_roles to allow upsert operations
-- Drop the existing policy that lacks WITH CHECK clause
DROP POLICY IF EXISTS "Users can edit DL roles for accessible models" ON public.dl_roles;

-- Recreate with both USING and WITH CHECK clauses
CREATE POLICY "Users can edit DL roles for accessible models"
ON public.dl_roles
FOR ALL
TO public
USING (
  EXISTS (
    SELECT 1
    FROM models m
    WHERE m.id = dl_roles.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM models m
    WHERE m.id = dl_roles.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
);