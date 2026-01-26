-- Drop the existing policy that only has USING clause
DROP POLICY IF EXISTS "Users can edit nonexempt positions for accessible models" ON nonexempt_positions;

-- Recreate with both USING and WITH CHECK clauses to support upsert operations
CREATE POLICY "Users can edit nonexempt positions for accessible models" 
  ON nonexempt_positions 
  FOR ALL 
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