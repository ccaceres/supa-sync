-- Create dl_roles_library table (model-specific DL Roles)
CREATE TABLE dl_roles_library (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES models(id) ON DELETE CASCADE,
  dl_role_name VARCHAR NOT NULL,
  nonexempt_position_id UUID NOT NULL REFERENCES nonexempt_positions(id) ON DELETE CASCADE,
  schedule_id UUID NOT NULL REFERENCES library_schedules(id) ON DELETE CASCADE,
  shift_1_percentage NUMERIC NOT NULL DEFAULT 100 CHECK (shift_1_percentage >= 0 AND shift_1_percentage <= 100),
  shift_2_percentage NUMERIC NOT NULL DEFAULT 0 CHECK (shift_2_percentage >= 0 AND shift_2_percentage <= 100),
  shift_3_percentage NUMERIC NOT NULL DEFAULT 0 CHECK (shift_3_percentage >= 0 AND shift_3_percentage <= 100),
  temp_percentage NUMERIC NOT NULL DEFAULT 0 CHECK (temp_percentage >= 0 AND temp_percentage <= 100),
  annual_inflation_percentage NUMERIC NOT NULL DEFAULT 3,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT shift_total_100 CHECK (shift_1_percentage + shift_2_percentage + shift_3_percentage = 100)
);

-- Add RLS policies
ALTER TABLE dl_roles_library ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view DL roles for accessible models"
  ON dl_roles_library FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = dl_roles_library.model_id
      AND can_access_project(auth.uid(), m.project_id)
    )
  );

CREATE POLICY "Users can edit DL roles for editable models"
  ON dl_roles_library FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = dl_roles_library.model_id
      AND can_edit_project(auth.uid(), m.project_id)
    )
  );

-- Add dl_role_library_id reference to dl_roles (LABEX tasks)
ALTER TABLE dl_roles 
ADD COLUMN dl_role_library_id UUID REFERENCES dl_roles_library(id) ON DELETE SET NULL;

COMMENT ON COLUMN dl_roles.dl_role_library_id IS 'Reference to model DL Role definition';

-- Create trigger for updated_at
CREATE TRIGGER update_dl_roles_library_updated_at
  BEFORE UPDATE ON dl_roles_library
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();