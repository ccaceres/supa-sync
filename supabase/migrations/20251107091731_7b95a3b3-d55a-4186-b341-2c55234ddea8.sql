
-- Fix CAPEX formula variables to use context source instead of capex source
-- This allows the FormulaEngine to properly resolve variables that are already in the context

UPDATE formula_definitions
SET variables = '[
  {"key": "UTC", "source": "calculated", "formula_reference": "capex_updated_total_cost"},
  {"key": "PercentCharged", "source": "context", "field": "PercentCharged"},
  {"key": "UpfrontMarkup", "source": "context", "field": "UpfrontMarkup"}
]'::jsonb
WHERE formula_key = 'capex_upfront_recovery';

UPDATE formula_definitions
SET variables = '[
  {"key": "UTC", "source": "calculated", "formula_reference": "capex_updated_total_cost"},
  {"key": "PercentCharged", "source": "context", "field": "PercentCharged"},
  {"key": "NAM", "source": "context", "field": "NAM"},
  {"key": "AAR", "source": "context", "field": "AAR"}
]'::jsonb
WHERE formula_key = 'capex_monthly_amortized_recovery';
