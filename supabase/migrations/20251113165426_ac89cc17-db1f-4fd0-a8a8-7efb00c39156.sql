-- Drop the existing policy that's missing WITH CHECK clause
DROP POLICY IF EXISTS "Users can edit price lines for accessible models" ON price_lines;

-- Recreate with proper WITH CHECK clause for upsert operations
CREATE POLICY "Users can edit price lines for accessible models"
ON price_lines
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = price_lines.model_id
    AND can_edit_project(auth.uid(), m.project_id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = price_lines.model_id
    AND can_edit_project(auth.uid(), m.project_id)
  )
);