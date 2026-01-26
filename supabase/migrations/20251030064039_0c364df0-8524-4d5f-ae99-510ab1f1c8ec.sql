-- Add formula template tracking columns to models table
ALTER TABLE public.models 
ADD COLUMN IF NOT EXISTS formula_template_name TEXT DEFAULT 'zulu_standard',
ADD COLUMN IF NOT EXISTS formula_template_version INTEGER;

-- Add comment to explain the columns
COMMENT ON COLUMN public.models.formula_template_name IS 'The formula template used when creating this model (e.g., zulu_standard)';
COMMENT ON COLUMN public.models.formula_template_version IS 'The version of the formula template used when creating this model';

-- Create an index for faster lookups
CREATE INDEX IF NOT EXISTS idx_models_formula_template ON public.models(formula_template_name, formula_template_version);