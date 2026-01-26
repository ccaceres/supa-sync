-- Fix RLS policies for equipment_sets and equipment_set_items to support upsert operations
-- Add WITH CHECK clause to validate new rows on INSERT/UPDATE

DROP POLICY IF EXISTS "Users can edit equipment sets for editable models" ON equipment_sets;

CREATE POLICY "Users can edit equipment sets for editable models" 
ON equipment_sets FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = equipment_sets.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = equipment_sets.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
);

DROP POLICY IF EXISTS "Users can edit equipment set items for editable sets" ON equipment_set_items;

CREATE POLICY "Users can edit equipment set items for editable sets" 
ON equipment_set_items FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM equipment_sets es
    JOIN models m ON m.id = es.model_id
    WHERE es.id = equipment_set_items.equipment_set_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM equipment_sets es
    JOIN models m ON m.id = es.model_id
    WHERE es.id = equipment_set_items.equipment_set_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
);