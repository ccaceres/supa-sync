-- Part 5: Update existing model formula_definitions for CAII%
-- This syncs all non-overridden CAII formulas with the updated template
UPDATE formula_definitions fd
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
WHERE 
  formula_key = 'cumulative_annual_inflation_indirect'
  AND is_overridden = false;