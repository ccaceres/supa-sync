-- Create library_dl_roles table
CREATE TABLE library_dl_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Basic Information
  dl_role_name VARCHAR NOT NULL,
  description TEXT,
  
  -- References to other library objects
  dl_position_id UUID NOT NULL REFERENCES library_direct_roles(id) ON DELETE RESTRICT,
  schedule_id UUID NOT NULL REFERENCES library_schedules(id) ON DELETE RESTRICT,
  
  -- Shift Split Configuration (must total 100%)
  shift_1_percentage NUMERIC NOT NULL DEFAULT 100 CHECK (shift_1_percentage >= 0 AND shift_1_percentage <= 100),
  shift_2_percentage NUMERIC NOT NULL DEFAULT 0 CHECK (shift_2_percentage >= 0 AND shift_2_percentage <= 100),
  shift_3_percentage NUMERIC NOT NULL DEFAULT 0 CHECK (shift_3_percentage >= 0 AND shift_3_percentage <= 100),
  
  -- Labor Mix
  temp_percentage NUMERIC NOT NULL DEFAULT 0 CHECK (temp_percentage >= 0 AND temp_percentage <= 100),
  
  -- Financial
  annual_inflation_percentage NUMERIC NOT NULL DEFAULT 3 CHECK (annual_inflation_percentage >= 0 AND annual_inflation_percentage <= 100),
  
  -- System fields
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_by UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  -- Constraint: Shift splits must total 100%
  CONSTRAINT valid_shift_split CHECK (
    shift_1_percentage + shift_2_percentage + shift_3_percentage = 100
  )
);

-- Indexes
CREATE INDEX idx_dl_roles_position ON library_dl_roles(dl_position_id);
CREATE INDEX idx_dl_roles_schedule ON library_dl_roles(schedule_id);
CREATE INDEX idx_dl_roles_active ON library_dl_roles(is_active);
CREATE INDEX idx_dl_roles_name ON library_dl_roles(dl_role_name);

-- RLS Policies
ALTER TABLE library_dl_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view DL roles"
  ON library_dl_roles FOR SELECT
  TO authenticated
  USING (has_permission(auth.uid(), 'library.view'::permission_type));

CREATE POLICY "Users can create DL roles"
  ON library_dl_roles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update DL roles they created"
  ON library_dl_roles FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by);

CREATE POLICY "Users can delete DL roles they created"
  ON library_dl_roles FOR DELETE
  TO authenticated
  USING (auth.uid() = created_by);

-- Trigger for updated_at
CREATE TRIGGER update_library_dl_roles_updated_at
  BEFORE UPDATE ON library_dl_roles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Comments
COMMENT ON TABLE library_dl_roles IS 'Composite DL roles combining position, schedule, shift splits, and labor mix';
COMMENT ON CONSTRAINT valid_shift_split ON library_dl_roles IS 'Shift 1%, 2%, and 3% must sum to exactly 100%';