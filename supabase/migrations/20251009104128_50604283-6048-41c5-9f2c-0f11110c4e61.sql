-- Drop existing direct roles tables and recreate with new schema
-- This migration restructures Direct Roles to support Permanent vs Temporary/Contract labor

-- Drop existing tables
DROP TABLE IF EXISTS library_direct_roles CASCADE;
DROP TABLE IF EXISTS direct_roles CASCADE;

-- Create library_direct_roles with new schema
CREATE TABLE library_direct_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Basic Information
  position_name VARCHAR NOT NULL,
  project VARCHAR,
  year INTEGER NOT NULL DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER,
  currency VARCHAR NOT NULL DEFAULT 'USD',
  market_percentile NUMERIC CHECK (market_percentile >= 0 AND market_percentile <= 100),
  
  -- Location
  country VARCHAR NOT NULL,
  state VARCHAR,
  city VARCHAR,
  
  -- Permanent Employee Compensation
  perm_wage_per_hour NUMERIC NOT NULL DEFAULT 0 CHECK (perm_wage_per_hour >= 0),
  perm_fringe_straight_time NUMERIC NOT NULL DEFAULT 0 CHECK (perm_fringe_straight_time >= 0 AND perm_fringe_straight_time <= 100),
  perm_fringe_overtime NUMERIC NOT NULL DEFAULT 0 CHECK (perm_fringe_overtime >= 0 AND perm_fringe_overtime <= 100),
  perm_hiring_cost NUMERIC NOT NULL DEFAULT 0 CHECK (perm_hiring_cost >= 0),
  
  -- Temporary/Contract Compensation
  temp_wage_per_hour NUMERIC NOT NULL DEFAULT 0 CHECK (temp_wage_per_hour >= 0),
  temp_fringe_straight_time NUMERIC NOT NULL DEFAULT 0 CHECK (temp_fringe_straight_time >= 0 AND temp_fringe_straight_time <= 100),
  temp_fringe_overtime NUMERIC NOT NULL DEFAULT 0 CHECK (temp_fringe_overtime >= 0 AND temp_fringe_overtime <= 100),
  
  -- Shift Differentials & OT
  shift_2_adder NUMERIC DEFAULT 0 CHECK (shift_2_adder >= 0),
  shift_3_adder NUMERIC DEFAULT 0 CHECK (shift_3_adder >= 0),
  ot_multiplier_percentage NUMERIC DEFAULT 150 CHECK (ot_multiplier_percentage >= 100 AND ot_multiplier_percentage <= 300),
  
  -- Workforce Planning
  annual_attrition_rate NUMERIC DEFAULT 0 CHECK (annual_attrition_rate >= 0 AND annual_attrition_rate <= 100),
  
  -- System fields
  is_active BOOLEAN NOT NULL DEFAULT true,
  effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
  expiration_date DATE,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Create direct_roles with new schema (model-specific version)
CREATE TABLE direct_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES models(id) ON DELETE CASCADE,
  
  -- Basic Information
  position_name VARCHAR NOT NULL,
  project VARCHAR,
  year INTEGER NOT NULL DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER,
  currency VARCHAR NOT NULL DEFAULT 'USD',
  market_percentile NUMERIC CHECK (market_percentile >= 0 AND market_percentile <= 100),
  
  -- Location
  country VARCHAR NOT NULL,
  state VARCHAR,
  city VARCHAR,
  
  -- Permanent Employee Compensation
  perm_wage_per_hour NUMERIC NOT NULL DEFAULT 0 CHECK (perm_wage_per_hour >= 0),
  perm_fringe_straight_time NUMERIC NOT NULL DEFAULT 0 CHECK (perm_fringe_straight_time >= 0 AND perm_fringe_straight_time <= 100),
  perm_fringe_overtime NUMERIC NOT NULL DEFAULT 0 CHECK (perm_fringe_overtime >= 0 AND perm_fringe_overtime <= 100),
  perm_hiring_cost NUMERIC NOT NULL DEFAULT 0 CHECK (perm_hiring_cost >= 0),
  
  -- Temporary/Contract Compensation
  temp_wage_per_hour NUMERIC NOT NULL DEFAULT 0 CHECK (temp_wage_per_hour >= 0),
  temp_fringe_straight_time NUMERIC NOT NULL DEFAULT 0 CHECK (temp_fringe_straight_time >= 0 AND temp_fringe_straight_time <= 100),
  temp_fringe_overtime NUMERIC NOT NULL DEFAULT 0 CHECK (temp_fringe_overtime >= 0 AND temp_fringe_overtime <= 100),
  
  -- Shift Differentials & OT
  shift_2_adder NUMERIC DEFAULT 0 CHECK (shift_2_adder >= 0),
  shift_3_adder NUMERIC DEFAULT 0 CHECK (shift_3_adder >= 0),
  ot_multiplier_percentage NUMERIC DEFAULT 150 CHECK (ot_multiplier_percentage >= 100 AND ot_multiplier_percentage <= 300),
  
  -- Workforce Planning
  annual_attrition_rate NUMERIC DEFAULT 0 CHECK (annual_attrition_rate >= 0 AND annual_attrition_rate <= 100),
  
  -- Hours allocation (10 years)
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
  
  -- Library linkage
  library_source_id UUID REFERENCES library_direct_roles(id) ON DELETE SET NULL,
  is_linked BOOLEAN DEFAULT false,
  override_fields JSONB DEFAULT '{}'::jsonb,
  local_version INTEGER DEFAULT 1,
  
  -- Status
  status VARCHAR DEFAULT 'active',
  
  -- System fields
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add indexes for library_direct_roles
CREATE INDEX idx_library_direct_roles_country ON library_direct_roles(country);
CREATE INDEX idx_library_direct_roles_position ON library_direct_roles(position_name);
CREATE INDEX idx_library_direct_roles_year ON library_direct_roles(year);
CREATE INDEX idx_library_direct_roles_active ON library_direct_roles(is_active);
CREATE INDEX idx_library_direct_roles_created_by ON library_direct_roles(created_by);

-- Add indexes for direct_roles
CREATE INDEX idx_direct_roles_model_id ON direct_roles(model_id);
CREATE INDEX idx_direct_roles_library_source ON direct_roles(library_source_id);
CREATE INDEX idx_direct_roles_position ON direct_roles(position_name);
CREATE INDEX idx_direct_roles_country ON direct_roles(country);
CREATE INDEX idx_direct_roles_status ON direct_roles(status);

-- Enable RLS
ALTER TABLE library_direct_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE direct_roles ENABLE ROW LEVEL SECURITY;

-- RLS Policies for library_direct_roles
CREATE POLICY "Authenticated users with library view permission can see direct roles"
  ON library_direct_roles FOR SELECT
  TO authenticated
  USING (has_permission(auth.uid(), 'library.view'::permission_type));

CREATE POLICY "Users can create library direct roles"
  ON library_direct_roles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update library direct roles they created"
  ON library_direct_roles FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by);

CREATE POLICY "Users can delete library direct roles they created"
  ON library_direct_roles FOR DELETE
  TO authenticated
  USING (auth.uid() = created_by);

-- RLS Policies for direct_roles
CREATE POLICY "Users can view direct roles for accessible models"
  ON direct_roles FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = direct_roles.model_id
      AND can_access_project(auth.uid(), m.project_id)
    )
  );

CREATE POLICY "Users can edit direct roles for accessible models"
  ON direct_roles FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = direct_roles.model_id
      AND can_edit_project(auth.uid(), m.project_id)
    )
  );

-- Add trigger for updated_at
CREATE TRIGGER update_library_direct_roles_updated_at
  BEFORE UPDATE ON library_direct_roles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_direct_roles_updated_at
  BEFORE UPDATE ON direct_roles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add comments
COMMENT ON TABLE library_direct_roles IS 'Library of reusable direct labor roles with permanent and temporary compensation structures';
COMMENT ON TABLE direct_roles IS 'Model-specific direct labor roles with hours allocation across 10 years';
COMMENT ON COLUMN library_direct_roles.market_percentile IS 'Market percentile for compensation (0-100, e.g., 50 = median)';
COMMENT ON COLUMN library_direct_roles.perm_wage_per_hour IS 'Permanent employee base wage per hour';
COMMENT ON COLUMN library_direct_roles.temp_wage_per_hour IS 'Temporary/contract worker wage per hour';
COMMENT ON COLUMN library_direct_roles.ot_multiplier_percentage IS 'Overtime multiplier as percentage (e.g., 150 = 1.5x)';
COMMENT ON COLUMN library_direct_roles.annual_attrition_rate IS 'Expected annual turnover rate as percentage';