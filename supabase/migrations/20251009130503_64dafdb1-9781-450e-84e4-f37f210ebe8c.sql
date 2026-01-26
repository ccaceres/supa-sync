-- Drop table if it exists from previous attempt
DROP TABLE IF EXISTS dl_roles CASCADE;

-- Create model-specific DL Roles table
CREATE TABLE dl_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES models(id) ON DELETE CASCADE,
  
  -- Link to library source (optional - can be standalone or library-linked)
  library_source_id UUID REFERENCES library_dl_roles(id) ON DELETE SET NULL,
  
  -- Basic Information (copied from library or custom)
  dl_role_name VARCHAR NOT NULL,
  description TEXT,
  
  -- References within this model (not library references!)
  dl_position_id UUID NOT NULL REFERENCES direct_roles(id) ON DELETE RESTRICT,
  schedule_id UUID REFERENCES library_schedules(id) ON DELETE RESTRICT,
  
  -- Shift Split Configuration
  shift_1_percentage NUMERIC NOT NULL DEFAULT 100 CHECK (shift_1_percentage >= 0 AND shift_1_percentage <= 100),
  shift_2_percentage NUMERIC NOT NULL DEFAULT 0 CHECK (shift_2_percentage >= 0 AND shift_2_percentage <= 100),
  shift_3_percentage NUMERIC NOT NULL DEFAULT 0 CHECK (shift_3_percentage >= 0 AND shift_3_percentage <= 100),
  
  -- Labor Mix
  temp_percentage NUMERIC NOT NULL DEFAULT 0 CHECK (temp_percentage >= 0 AND temp_percentage <= 100),
  
  -- Financial
  annual_inflation_percentage NUMERIC NOT NULL DEFAULT 3 CHECK (annual_inflation_percentage >= 0 AND annual_inflation_percentage <= 100),
  
  -- Hours allocation (similar to direct_roles)
  hours_year_1 NUMERIC DEFAULT 0,
  hours_year_2 NUMERIC DEFAULT 0,
  hours_year_3 NUMERIC DEFAULT 0,
  hours_year_4 NUMERIC DEFAULT 0,
  hours_year_5 NUMERIC DEFAULT 0,
  hours_year_6 NUMERIC DEFAULT 0,
  hours_year_7 NUMERIC DEFAULT 0,
  hours_year_8 NUMERIC DEFAULT 0,
  hours_year_9 NUMERIC DEFAULT 0,
  hours_year_10 NUMERIC DEFAULT 0,
  
  -- Override tracking
  is_rate_overridden BOOLEAN DEFAULT false,
  is_schedule_overridden BOOLEAN DEFAULT false,
  
  -- System fields
  status VARCHAR DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  -- Constraint: Shift splits must total 100%
  CONSTRAINT valid_shift_split CHECK (
    shift_1_percentage + shift_2_percentage + shift_3_percentage = 100
  )
);

-- Indexes for performance
CREATE INDEX idx_dl_roles_model_id ON dl_roles(model_id);
CREATE INDEX idx_dl_roles_dl_position_id ON dl_roles(dl_position_id);
CREATE INDEX idx_dl_roles_schedule_id ON dl_roles(schedule_id);
CREATE INDEX idx_dl_roles_library_source_id ON dl_roles(library_source_id);

-- Enable Row Level Security
ALTER TABLE dl_roles ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view DL roles for accessible models
CREATE POLICY "Users can view DL roles for accessible models"
  ON dl_roles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = dl_roles.model_id
      AND can_access_project(auth.uid(), m.project_id)
    )
  );

-- RLS Policy: Users can edit DL roles for editable models
CREATE POLICY "Users can edit DL roles for accessible models"
  ON dl_roles FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = dl_roles.model_id
      AND can_edit_project(auth.uid(), m.project_id)
    )
  );

-- Trigger to update updated_at timestamp
CREATE TRIGGER update_dl_roles_updated_at
  BEFORE UPDATE ON dl_roles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();