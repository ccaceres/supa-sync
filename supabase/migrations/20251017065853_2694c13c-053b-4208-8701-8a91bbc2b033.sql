-- Phase 1: Formula Engine Database Schema

-- Step 1: Add paid_absentee_days_off_per_year to library_schedules
ALTER TABLE library_schedules 
ADD COLUMN IF NOT EXISTS paid_absentee_days_off_per_year NUMERIC DEFAULT 8;

-- Step 2: Create wage_inflation_schedules table
CREATE TABLE IF NOT EXISTS wage_inflation_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES models(id) ON DELETE CASCADE,
  name VARCHAR NOT NULL,
  description TEXT,
  
  -- Inflation rates for 20 years (stored as percentages, e.g., 2.5 = 2.5%)
  inflation_year_1 NUMERIC DEFAULT 0,
  inflation_year_2 NUMERIC DEFAULT 0,
  inflation_year_3 NUMERIC DEFAULT 0,
  inflation_year_4 NUMERIC DEFAULT 0,
  inflation_year_5 NUMERIC DEFAULT 0,
  inflation_year_6 NUMERIC DEFAULT 0,
  inflation_year_7 NUMERIC DEFAULT 0,
  inflation_year_8 NUMERIC DEFAULT 0,
  inflation_year_9 NUMERIC DEFAULT 0,
  inflation_year_10 NUMERIC DEFAULT 0,
  inflation_year_11 NUMERIC DEFAULT 0,
  inflation_year_12 NUMERIC DEFAULT 0,
  inflation_year_13 NUMERIC DEFAULT 0,
  inflation_year_14 NUMERIC DEFAULT 0,
  inflation_year_15 NUMERIC DEFAULT 0,
  inflation_year_16 NUMERIC DEFAULT 0,
  inflation_year_17 NUMERIC DEFAULT 0,
  inflation_year_18 NUMERIC DEFAULT 0,
  inflation_year_19 NUMERIC DEFAULT 0,
  inflation_year_20 NUMERIC DEFAULT 0,
  
  is_active BOOLEAN DEFAULT TRUE,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_wage_inflation_schedules_model ON wage_inflation_schedules(model_id);

-- Step 3: Add wage_inflation_schedule_id to dl_roles
ALTER TABLE dl_roles 
ADD COLUMN IF NOT EXISTS wage_inflation_schedule_id UUID REFERENCES wage_inflation_schedules(id) ON DELETE SET NULL;

-- Step 4: Create formula_definitions table
CREATE TABLE IF NOT EXISTS formula_definitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID REFERENCES models(id) ON DELETE CASCADE,
  formula_key TEXT NOT NULL,
  display_name TEXT NOT NULL,
  category TEXT NOT NULL,
  
  -- Formula expression (Excel-like syntax)
  expression TEXT NOT NULL,
  
  -- Variables used in this formula (JSON array)
  variables JSONB NOT NULL DEFAULT '[]'::jsonb,
  
  -- Result configuration
  result_type TEXT NOT NULL DEFAULT 'number',
  result_unit TEXT,
  decimal_places INTEGER DEFAULT 2,
  
  -- Dependencies (other formulas this depends on)
  depends_on TEXT[] DEFAULT '{}',
  
  -- Metadata
  description TEXT,
  example_calculation TEXT,
  tooltip_template TEXT,
  
  -- Version control
  version INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT TRUE,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(model_id, formula_key, version)
);

CREATE INDEX idx_formula_definitions_model ON formula_definitions(model_id);
CREATE INDEX idx_formula_definitions_key ON formula_definitions(formula_key);
CREATE INDEX idx_formula_definitions_category ON formula_definitions(category);

-- Step 5: Create formula_variables table
CREATE TABLE IF NOT EXISTS formula_variables (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID REFERENCES models(id) ON DELETE CASCADE,
  
  variable_key TEXT NOT NULL,
  display_name TEXT NOT NULL,
  category TEXT NOT NULL,
  
  -- Data source configuration
  source_type TEXT NOT NULL,
  source_table TEXT,
  source_field TEXT,
  
  -- For calculated variables that reference other formulas
  formula_reference TEXT,
  
  -- Type and validation
  data_type TEXT NOT NULL DEFAULT 'number',
  default_value NUMERIC,
  min_value NUMERIC,
  max_value NUMERIC,
  
  -- UI configuration
  description TEXT,
  unit TEXT,
  tooltip TEXT,
  
  -- Metadata
  is_system BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(model_id, variable_key)
);

CREATE INDEX idx_formula_variables_model ON formula_variables(model_id);
CREATE INDEX idx_formula_variables_category ON formula_variables(category);

-- Step 6: Create formula_templates table
CREATE TABLE IF NOT EXISTS formula_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  template_name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  
  -- Template definitions (multiple formulas)
  formulas JSONB NOT NULL DEFAULT '[]'::jsonb,
  
  -- Usage tracking
  usage_count INTEGER DEFAULT 0,
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_formula_templates_category ON formula_templates(category);

-- Step 7: Create formula_audit_log table
CREATE TABLE IF NOT EXISTS formula_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  formula_id UUID REFERENCES formula_definitions(id) ON DELETE SET NULL,
  
  action TEXT NOT NULL,
  old_expression TEXT,
  new_expression TEXT,
  
  changed_by UUID REFERENCES auth.users(id),
  change_reason TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_formula_audit_log_formula ON formula_audit_log(formula_id);
CREATE INDEX idx_formula_audit_log_date ON formula_audit_log(created_at);

-- Step 8: Enable RLS on all new tables
ALTER TABLE wage_inflation_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE formula_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE formula_variables ENABLE ROW LEVEL SECURITY;
ALTER TABLE formula_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE formula_audit_log ENABLE ROW LEVEL SECURITY;

-- Step 9: Create RLS policies for wage_inflation_schedules
CREATE POLICY "Users can view wage inflation schedules for accessible models"
ON wage_inflation_schedules FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = wage_inflation_schedules.model_id
    AND can_access_project(auth.uid(), m.project_id)
  )
);

CREATE POLICY "Users can edit wage inflation schedules for editable models"
ON wage_inflation_schedules FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = wage_inflation_schedules.model_id
    AND can_edit_project(auth.uid(), m.project_id)
  )
);

-- Step 10: Create RLS policies for formula_definitions
CREATE POLICY "Users can view formula definitions for accessible models"
ON formula_definitions FOR SELECT
USING (
  model_id IS NULL OR
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = formula_definitions.model_id
    AND can_access_project(auth.uid(), m.project_id)
  )
);

CREATE POLICY "Users can edit formula definitions for editable models"
ON formula_definitions FOR ALL
USING (
  model_id IS NULL OR
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = formula_definitions.model_id
    AND can_edit_project(auth.uid(), m.project_id)
  )
);

-- Step 11: Create RLS policies for formula_variables
CREATE POLICY "Users can view formula variables for accessible models"
ON formula_variables FOR SELECT
USING (
  model_id IS NULL OR
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = formula_variables.model_id
    AND can_access_project(auth.uid(), m.project_id)
  )
);

CREATE POLICY "Users can edit formula variables for editable models"
ON formula_variables FOR ALL
USING (
  model_id IS NULL OR
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = formula_variables.model_id
    AND can_edit_project(auth.uid(), m.project_id)
  )
);

-- Step 12: Create RLS policies for formula_templates
CREATE POLICY "Anyone can view formula templates"
ON formula_templates FOR SELECT
USING (true);

CREATE POLICY "Admins can manage formula templates"
ON formula_templates FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role));

-- Step 13: Create RLS policies for formula_audit_log
CREATE POLICY "Users can view audit logs for accessible formulas"
ON formula_audit_log FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM formula_definitions fd
    JOIN models m ON m.id = fd.model_id
    WHERE fd.id = formula_audit_log.formula_id
    AND can_access_project(auth.uid(), m.project_id)
  )
);

-- Step 14: Create trigger for updated_at on wage_inflation_schedules
CREATE TRIGGER update_wage_inflation_schedules_updated_at
BEFORE UPDATE ON wage_inflation_schedules
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Step 15: Create trigger for updated_at on formula_definitions
CREATE TRIGGER update_formula_definitions_updated_at
BEFORE UPDATE ON formula_definitions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Step 16: Create trigger for updated_at on formula_variables
CREATE TRIGGER update_formula_variables_updated_at
BEFORE UPDATE ON formula_variables
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Step 17: Create trigger for updated_at on formula_templates
CREATE TRIGGER update_formula_templates_updated_at
BEFORE UPDATE ON formula_templates
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();