-- Part 1: Add annual_inflation_rate to library_exempt_positions
ALTER TABLE library_exempt_positions 
ADD COLUMN IF NOT EXISTS annual_inflation_rate NUMERIC DEFAULT 3.0;

COMMENT ON COLUMN library_exempt_positions.annual_inflation_rate IS 'Annual inflation rate percentage for cost escalation (e.g., 3.0 for 3%)';

-- Part 2: Add annual_inflation_rate to exempt_positions (model-specific)
ALTER TABLE exempt_positions 
ADD COLUMN IF NOT EXISTS annual_inflation_rate NUMERIC DEFAULT 3.0;

COMMENT ON COLUMN exempt_positions.annual_inflation_rate IS 'Annual inflation rate percentage for cost escalation (e.g., 3.0 for 3%)';

-- Part 3: Update existing records to use annual_inflation_percentage if it exists
UPDATE library_exempt_positions 
SET annual_inflation_rate = 3.0 
WHERE annual_inflation_rate IS NULL;

UPDATE exempt_positions 
SET annual_inflation_rate = 3.0 
WHERE annual_inflation_rate IS NULL;

-- Part 4: Update the CAII% formula template
UPDATE formula_templates 
SET 
  category = 'indirect_cost',
  expression = 'PriorYearCAII * (1 + AnnualInflation / 100)',
  variables = '[
    {"key": "PriorYearCAII", "source": "calculated", "description": "CAII from prior year (1.0 for year 1)"},
    {"key": "AnnualInflation", "source": "parameter", "field": "annual_inflation_rate", "description": "Annual inflation rate %"}
  ]'::jsonb,
  description = 'Cumulative annual inflation impact. Compounds year over year. Year 1 = 100%, Year 2 = (1+AI%), Year 3 = (1+AI%)², etc.',
  decimal_places = 4,
  example_calculation = 'Year 1: 1.0 (100%), Year 2 @ 3% inflation: 1.03 (103%), Year 3: 1.0609 (106.09%)',
  updated_at = NOW()
WHERE formula_key = 'cumulative_annual_inflation_indirect';