-- Fix volumes table RLS policies to enable price sync from price_lines updates
-- The existing ALL policy may be blocking updates, so we'll create explicit policies

-- First, drop the existing ALL policy that might be too restrictive
DROP POLICY IF EXISTS "Users can edit volumes for accessible models" ON public.volumes;

-- Create separate policies for INSERT, UPDATE, and DELETE with explicit WITH CHECK clauses
CREATE POLICY "Users can insert volumes for accessible models"
ON public.volumes
FOR INSERT
TO public
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM models m
    WHERE m.id = volumes.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
);

CREATE POLICY "Users can update volumes for accessible models"
ON public.volumes
FOR UPDATE
TO public
USING (
  EXISTS (
    SELECT 1
    FROM models m
    WHERE m.id = volumes.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM models m
    WHERE m.id = volumes.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
);

CREATE POLICY "Users can delete volumes for accessible models"
ON public.volumes
FOR DELETE
TO public
USING (
  EXISTS (
    SELECT 1
    FROM models m
    WHERE m.id = volumes.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
);