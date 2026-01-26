-- Fix impex_yearly_cost formula: Change BaseCost and FinalCost to use context source
-- This prevents recursive formula evaluation and uses pre-calculated values

UPDATE formula_definitions
SET 
  variables = jsonb_set(
    jsonb_set(
      variables,
      '{2}',  -- Index of FinalCost variable
      '{"key": "FinalCost", "source": "context", "field": "FinalCost", "description": "Final cost with margin/markup (pre-calculated)"}'::jsonb
    ),
    '{3}',  -- Index of BaseCost variable
    '{"key": "BaseCost", "source": "context", "field": "BaseCost", "description": "Base cost for amortization (pre-calculated)"}'::jsonb
  ),
  updated_at = NOW()
WHERE formula_key = 'impex_yearly_cost';