-- Phase 1: Clean up nonexempt_positions (remove allocation fields, keep only rate card data)
ALTER TABLE nonexempt_positions 
  DROP COLUMN IF EXISTS hours_year_1,
  DROP COLUMN IF EXISTS hours_year_2,
  DROP COLUMN IF EXISTS hours_year_3,
  DROP COLUMN IF EXISTS hours_year_4,
  DROP COLUMN IF EXISTS hours_year_5,
  DROP COLUMN IF EXISTS hours_year_6,
  DROP COLUMN IF EXISTS hours_year_7,
  DROP COLUMN IF EXISTS hours_year_8,
  DROP COLUMN IF EXISTS hours_year_9,
  DROP COLUMN IF EXISTS hours_year_10,
  DROP COLUMN IF EXISTS hours_year_11,
  DROP COLUMN IF EXISTS hours_year_12,
  DROP COLUMN IF EXISTS hours_year_13,
  DROP COLUMN IF EXISTS hours_year_14,
  DROP COLUMN IF EXISTS hours_year_15,
  DROP COLUMN IF EXISTS hours_year_16,
  DROP COLUMN IF EXISTS hours_year_17,
  DROP COLUMN IF EXISTS hours_year_18,
  DROP COLUMN IF EXISTS hours_year_19,
  DROP COLUMN IF EXISTS hours_year_20,
  DROP COLUMN IF EXISTS driver_id,
  DROP COLUMN IF EXISTS driver_ratio,
  DROP COLUMN IF EXISTS auto_calculate_hours,
  DROP COLUMN IF EXISTS upph;

-- Phase 2: Clean up exempt_positions (remove allocation fields, keep only rate card data)
ALTER TABLE exempt_positions 
  DROP COLUMN IF EXISTS fte_year_1,
  DROP COLUMN IF EXISTS fte_year_2,
  DROP COLUMN IF EXISTS fte_year_3,
  DROP COLUMN IF EXISTS fte_year_4,
  DROP COLUMN IF EXISTS fte_year_5,
  DROP COLUMN IF EXISTS fte_year_6,
  DROP COLUMN IF EXISTS fte_year_7,
  DROP COLUMN IF EXISTS fte_year_8,
  DROP COLUMN IF EXISTS fte_year_9,
  DROP COLUMN IF EXISTS fte_year_10,
  DROP COLUMN IF EXISTS driver_id,
  DROP COLUMN IF EXISTS driver_ratio,
  DROP COLUMN IF EXISTS auto_calculate_fte,
  DROP COLUMN IF EXISTS upph;

-- Phase 3: Create LABEX Indirect Labor table
CREATE TABLE labex_indirect_labor (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES models(id) ON DELETE CASCADE,
  exempt_position_id UUID NOT NULL REFERENCES exempt_positions(id) ON DELETE RESTRICT,
  shift INTEGER NOT NULL DEFAULT 1 CHECK (shift IN (1, 2, 3)),
  fte_year_1 NUMERIC DEFAULT 0,
  fte_year_2 NUMERIC DEFAULT 0,
  fte_year_3 NUMERIC DEFAULT 0,
  fte_year_4 NUMERIC DEFAULT 0,
  fte_year_5 NUMERIC DEFAULT 0,
  fte_year_6 NUMERIC DEFAULT 0,
  fte_year_7 NUMERIC DEFAULT 0,
  fte_year_8 NUMERIC DEFAULT 0,
  fte_year_9 NUMERIC DEFAULT 0,
  fte_year_10 NUMERIC DEFAULT 0,
  fte_year_11 NUMERIC DEFAULT 0,
  fte_year_12 NUMERIC DEFAULT 0,
  fte_year_13 NUMERIC DEFAULT 0,
  fte_year_14 NUMERIC DEFAULT 0,
  fte_year_15 NUMERIC DEFAULT 0,
  fte_year_16 NUMERIC DEFAULT 0,
  fte_year_17 NUMERIC DEFAULT 0,
  fte_year_18 NUMERIC DEFAULT 0,
  fte_year_19 NUMERIC DEFAULT 0,
  fte_year_20 NUMERIC DEFAULT 0,
  annual_inflation_percentage NUMERIC NOT NULL DEFAULT 3,
  price_line_imposition INTEGER DEFAULT 1,
  row_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable RLS for labex_indirect_labor
ALTER TABLE labex_indirect_labor ENABLE ROW LEVEL SECURITY;

-- RLS Policies for labex_indirect_labor
CREATE POLICY "Users can view indirect labor for accessible models"
  ON labex_indirect_labor FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = labex_indirect_labor.model_id
      AND can_access_project(auth.uid(), m.project_id)
    )
  );

CREATE POLICY "Users can edit indirect labor for editable models"
  ON labex_indirect_labor FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = labex_indirect_labor.model_id
      AND can_edit_project(auth.uid(), m.project_id)
    )
  );

-- Add trigger for row_order
CREATE TRIGGER update_idl_row_order
  BEFORE INSERT ON labex_indirect_labor
  FOR EACH ROW
  EXECUTE FUNCTION update_dl_role_row_order();

-- Add trigger for updated_at
CREATE TRIGGER update_idl_updated_at
  BEFORE UPDATE ON labex_indirect_labor
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();