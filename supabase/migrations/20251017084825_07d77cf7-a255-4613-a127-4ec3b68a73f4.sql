-- Phase 1: Add linking and override columns to formula_definitions
ALTER TABLE formula_definitions
  ADD COLUMN IF NOT EXISTS library_formula_id UUID REFERENCES formula_templates(id),
  ADD COLUMN IF NOT EXISTS is_overridden BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS overridden_expression TEXT,
  ADD COLUMN IF NOT EXISTS original_expression TEXT,
  ADD COLUMN IF NOT EXISTS override_reason TEXT;

-- Phase 2: Restructure formula_templates to store individual formulas
ALTER TABLE formula_templates
  ADD COLUMN IF NOT EXISTS formula_key TEXT,
  ADD COLUMN IF NOT EXISTS expression TEXT,
  ADD COLUMN IF NOT EXISTS variables JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS depends_on TEXT[] DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS result_type TEXT DEFAULT 'number',
  ADD COLUMN IF NOT EXISTS result_unit TEXT,
  ADD COLUMN IF NOT EXISTS decimal_places INTEGER DEFAULT 2,
  ADD COLUMN IF NOT EXISTS example_calculation TEXT,
  ADD COLUMN IF NOT EXISTS tooltip_template TEXT,
  ADD COLUMN IF NOT EXISTS is_system BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS version INTEGER DEFAULT 1;

-- Create unique constraint for formula_key (global uniqueness)
CREATE UNIQUE INDEX IF NOT EXISTS idx_formula_templates_key 
ON formula_templates(formula_key) 
WHERE formula_key IS NOT NULL;

-- Create index for template_name lookups
CREATE INDEX IF NOT EXISTS idx_formula_templates_name 
ON formula_templates(template_name);

-- Add index for library_formula_id lookups
CREATE INDEX IF NOT EXISTS idx_formula_definitions_library 
ON formula_definitions(library_formula_id);

-- Add index for override status
CREATE INDEX IF NOT EXISTS idx_formula_definitions_override 
ON formula_definitions(is_overridden) 
WHERE is_overridden = TRUE;