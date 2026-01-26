-- Fix exempt_positions RLS policy to allow upsert operations
DROP POLICY IF EXISTS "Users can edit exempt positions for accessible models" ON exempt_positions;

CREATE POLICY "Users can edit exempt positions for accessible models"
ON exempt_positions
FOR ALL
TO public
USING (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = exempt_positions.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = exempt_positions.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
);

-- Fix nonexempt_positions RLS policy to allow upsert operations
DROP POLICY IF EXISTS "Users can edit nonexempt positions for accessible models" ON nonexempt_positions;

CREATE POLICY "Users can edit nonexempt positions for accessible models"
ON nonexempt_positions
FOR ALL
TO public
USING (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = nonexempt_positions.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = nonexempt_positions.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
);