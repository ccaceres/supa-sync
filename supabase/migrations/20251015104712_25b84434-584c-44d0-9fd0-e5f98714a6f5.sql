-- Phase 1: Create CI Schedules table and extend DL Roles for LABEX Tasks

-- 1A: Create ci_schedules table for continuous improvement schedules
CREATE TABLE IF NOT EXISTS ci_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES models(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  
  -- CI percentages for years 2-20 (Year 1 is always 0% - baseline)
  ci_year_2 NUMERIC DEFAULT 0,
  ci_year_3 NUMERIC DEFAULT 0,
  ci_year_4 NUMERIC DEFAULT 0,
  ci_year_5 NUMERIC DEFAULT 0,
  ci_year_6 NUMERIC DEFAULT 0,
  ci_year_7 NUMERIC DEFAULT 0,
  ci_year_8 NUMERIC DEFAULT 0,
  ci_year_9 NUMERIC DEFAULT 0,
  ci_year_10 NUMERIC DEFAULT 0,
  ci_year_11 NUMERIC DEFAULT 0,
  ci_year_12 NUMERIC DEFAULT 0,
  ci_year_13 NUMERIC DEFAULT 0,
  ci_year_14 NUMERIC DEFAULT 0,
  ci_year_15 NUMERIC DEFAULT 0,
  ci_year_16 NUMERIC DEFAULT 0,
  ci_year_17 NUMERIC DEFAULT 0,
  ci_year_18 NUMERIC DEFAULT 0,
  ci_year_19 NUMERIC DEFAULT 0,
  ci_year_20 NUMERIC DEFAULT 0,
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  
  CONSTRAINT ci_schedules_model_name_unique UNIQUE(model_id, name)
);

-- Index for fast lookups
CREATE INDEX IF NOT EXISTS idx_ci_schedules_model ON ci_schedules(model_id) WHERE is_active = true;

-- RLS Policies for ci_schedules
ALTER TABLE ci_schedules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view CI schedules for accessible models"
ON ci_schedules FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = ci_schedules.model_id 
    AND can_access_project(auth.uid(), m.project_id)
  )
);

CREATE POLICY "Users can edit CI schedules for editable models"
ON ci_schedules FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = ci_schedules.model_id 
    AND can_edit_project(auth.uid(), m.project_id)
  )
);

-- 1B: Extend dl_roles table for LABEX Tasks functionality
-- Add years 11-20
ALTER TABLE dl_roles
  ADD COLUMN IF NOT EXISTS hours_year_11 NUMERIC DEFAULT 0,
  ADD COLUMN IF NOT EXISTS hours_year_12 NUMERIC DEFAULT 0,
  ADD COLUMN IF NOT EXISTS hours_year_13 NUMERIC DEFAULT 0,
  ADD COLUMN IF NOT EXISTS hours_year_14 NUMERIC DEFAULT 0,
  ADD COLUMN IF NOT EXISTS hours_year_15 NUMERIC DEFAULT 0,
  ADD COLUMN IF NOT EXISTS hours_year_16 NUMERIC DEFAULT 0,
  ADD COLUMN IF NOT EXISTS hours_year_17 NUMERIC DEFAULT 0,
  ADD COLUMN IF NOT EXISTS hours_year_18 NUMERIC DEFAULT 0,
  ADD COLUMN IF NOT EXISTS hours_year_19 NUMERIC DEFAULT 0,
  ADD COLUMN IF NOT EXISTS hours_year_20 NUMERIC DEFAULT 0;

-- Add new required fields for LABEX Tasks
ALTER TABLE dl_roles
  ADD COLUMN IF NOT EXISTS uom VARCHAR(50) DEFAULT 'Units',
  ADD COLUMN IF NOT EXISTS row_order INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS volume_stream_id UUID REFERENCES volumes(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS ci_schedule_id UUID REFERENCES ci_schedules(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS equipment_set_id UUID REFERENCES equipment(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS upph NUMERIC,
  ADD COLUMN IF NOT EXISTS pf_d_percentage NUMERIC DEFAULT 0,
  ADD COLUMN IF NOT EXISTS ot_percentage NUMERIC DEFAULT 0,
  ADD COLUMN IF NOT EXISTS equipment_factor_percentage NUMERIC DEFAULT 0,
  ADD COLUMN IF NOT EXISTS price_line_imposition INTEGER DEFAULT 1;

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_dl_roles_volume_stream ON dl_roles(volume_stream_id);
CREATE INDEX IF NOT EXISTS idx_dl_roles_ci_schedule ON dl_roles(ci_schedule_id);
CREATE INDEX IF NOT EXISTS idx_dl_roles_row_order ON dl_roles(model_id, row_order);

-- Trigger for automatic row_order assignment
CREATE OR REPLACE FUNCTION update_dl_role_row_order()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF NEW.row_order IS NULL OR NEW.row_order = 0 THEN
    SELECT COALESCE(MAX(row_order), 0) + 1 
    INTO NEW.row_order 
    FROM dl_roles 
    WHERE model_id = NEW.model_id;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS dl_role_row_order_trigger ON dl_roles;
CREATE TRIGGER dl_role_row_order_trigger
BEFORE INSERT ON dl_roles
FOR EACH ROW EXECUTE FUNCTION update_dl_role_row_order();