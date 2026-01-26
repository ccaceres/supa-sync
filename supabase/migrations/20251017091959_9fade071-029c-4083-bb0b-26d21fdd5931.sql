-- Fix formula_templates unique constraint to allow multiple formulas per template
-- Currently the constraint is on template_name alone, but we need multiple rows per template

-- Drop the existing constraint that blocks multiple rows with same template_name
ALTER TABLE formula_templates 
DROP CONSTRAINT IF EXISTS formula_templates_template_name_key;

-- Add a proper unique constraint on (template_name, formula_key)
-- This allows multiple formulas per template, but each formula_key must be unique within a template
-- For metadata rows (where formula_key IS NULL), we allow only one per template_name
CREATE UNIQUE INDEX formula_templates_unique_idx 
ON formula_templates (template_name, COALESCE(formula_key, '__metadata__'));