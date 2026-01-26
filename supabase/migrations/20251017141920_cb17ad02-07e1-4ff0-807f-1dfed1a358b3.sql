-- Phase 1: Update library_dl_roles table structure
-- Ensure all required fields exist
ALTER TABLE library_dl_roles 
ADD COLUMN IF NOT EXISTS nonexempt_position_id UUID REFERENCES library_nonexempt_positions(id);

-- Add missing fields if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='library_dl_roles' AND column_name='annual_inflation_percentage') THEN
    ALTER TABLE library_dl_roles ADD COLUMN annual_inflation_percentage NUMERIC NOT NULL DEFAULT 3;
  END IF;
END $$;

-- Add constraint for shift percentages
ALTER TABLE library_dl_roles DROP CONSTRAINT IF EXISTS shift_percentages_sum_100;
ALTER TABLE library_dl_roles ADD CONSTRAINT shift_percentages_sum_100 
CHECK (shift_1_percentage + shift_2_percentage + shift_3_percentage = 100);

-- Phase 2: Add library_dl_role_id to dl_roles
ALTER TABLE dl_roles 
ADD COLUMN IF NOT EXISTS library_dl_role_id UUID REFERENCES library_dl_roles(id);

-- Phase 3: Create equipment_sets table if not exists
CREATE TABLE IF NOT EXISTS equipment_sets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES models(id) ON DELETE CASCADE,
  set_name VARCHAR NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable RLS on equipment_sets
ALTER TABLE equipment_sets ENABLE ROW LEVEL SECURITY;

-- RLS policies for equipment_sets
DROP POLICY IF EXISTS "Users can view equipment sets for accessible models" ON equipment_sets;
CREATE POLICY "Users can view equipment sets for accessible models" 
ON equipment_sets FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = equipment_sets.model_id 
    AND can_access_project(auth.uid(), m.project_id)
  )
);

DROP POLICY IF EXISTS "Users can edit equipment sets for editable models" ON equipment_sets;
CREATE POLICY "Users can edit equipment sets for editable models" 
ON equipment_sets FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = equipment_sets.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
);

-- Create equipment_set_items junction table
CREATE TABLE IF NOT EXISTS equipment_set_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  equipment_set_id UUID NOT NULL REFERENCES equipment_sets(id) ON DELETE CASCADE,
  equipment_id UUID NOT NULL REFERENCES equipment(id) ON DELETE CASCADE,
  quantity NUMERIC NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(equipment_set_id, equipment_id)
);

-- Enable RLS on equipment_set_items
ALTER TABLE equipment_set_items ENABLE ROW LEVEL SECURITY;

-- RLS policies for equipment_set_items
DROP POLICY IF EXISTS "Users can view equipment set items for accessible sets" ON equipment_set_items;
CREATE POLICY "Users can view equipment set items for accessible sets" 
ON equipment_set_items FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM equipment_sets es
    JOIN models m ON m.id = es.model_id
    WHERE es.id = equipment_set_items.equipment_set_id 
    AND can_access_project(auth.uid(), m.project_id)
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
);

-- Phase 4: Update equipment_set_id foreign key in dl_roles to reference equipment_sets
-- First drop the old foreign key constraint
ALTER TABLE dl_roles DROP CONSTRAINT IF EXISTS dl_roles_equipment_set_id_fkey;

-- Add new foreign key constraint to equipment_sets
ALTER TABLE dl_roles 
ADD CONSTRAINT dl_roles_equipment_set_id_fkey 
FOREIGN KEY (equipment_set_id) REFERENCES equipment_sets(id);

-- Phase 5: Trigger for updated_at on equipment_sets
CREATE OR REPLACE FUNCTION update_equipment_sets_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_equipment_sets_updated_at ON equipment_sets;
CREATE TRIGGER update_equipment_sets_updated_at
  BEFORE UPDATE ON equipment_sets
  FOR EACH ROW
  EXECUTE FUNCTION update_equipment_sets_updated_at();

-- Phase 6: Migration for existing dl_roles data
-- Create library DL roles from existing dl_roles that don't have a library reference
INSERT INTO library_dl_roles (
  dl_role_name,
  description,
  nonexempt_position_id,
  schedule_id,
  shift_1_percentage,
  shift_2_percentage,
  shift_3_percentage,
  temp_percentage,
  annual_inflation_percentage,
  created_by,
  is_active
)
SELECT DISTINCT
  'Generated: ' || dr.dl_role_name,
  'Auto-generated from existing task: ' || dr.dl_role_name,
  dr.nonexempt_position_id,
  COALESCE(dr.schedule_id, (SELECT id FROM library_schedules LIMIT 1)),
  dr.shift_1_percentage,
  dr.shift_2_percentage,
  dr.shift_3_percentage,
  dr.temp_percentage,
  dr.annual_inflation_percentage,
  (SELECT user_id FROM profiles LIMIT 1), -- Use first user as creator
  true
FROM dl_roles dr
WHERE dr.library_dl_role_id IS NULL
  AND dr.schedule_id IS NOT NULL
ON CONFLICT DO NOTHING;

-- Link existing dl_roles to the newly created library entries
UPDATE dl_roles dr
SET library_dl_role_id = ldr.id
FROM library_dl_roles ldr
WHERE dr.library_dl_role_id IS NULL
  AND dr.nonexempt_position_id = ldr.nonexempt_position_id
  AND dr.schedule_id = ldr.schedule_id
  AND dr.shift_1_percentage = ldr.shift_1_percentage
  AND dr.shift_2_percentage = ldr.shift_2_percentage
  AND dr.shift_3_percentage = ldr.shift_3_percentage
  AND dr.temp_percentage = ldr.temp_percentage
  AND ldr.dl_role_name LIKE 'Generated: %';