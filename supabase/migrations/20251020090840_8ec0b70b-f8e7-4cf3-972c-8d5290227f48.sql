-- Fix RLS policy for labex_indirect_labor to include WITH CHECK clause
DROP POLICY IF EXISTS "Users can edit indirect labor for editable models" ON labex_indirect_labor;

CREATE POLICY "Users can edit indirect labor for editable models"
ON labex_indirect_labor
FOR ALL
TO public
USING (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = labex_indirect_labor.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = labex_indirect_labor.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
);