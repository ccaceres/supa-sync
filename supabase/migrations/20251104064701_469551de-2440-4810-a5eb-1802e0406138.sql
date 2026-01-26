-- Fix impex_yearly_cost formula: Remove duplicates and add missing IsUpfront variable

-- First, delete all existing impex_yearly_cost formulas
DELETE FROM formula_definitions WHERE formula_key = 'impex_yearly_cost';

-- Insert the correct formula with all required variables including IsUpfront
INSERT INTO formula_definitions (
  formula_key,
  display_name,
  expression,
  result_type,
  category,
  description,
  variables,
  depends_on,
  is_active,
  version,
  created_at,
  updated_at
) VALUES (
  'impex_yearly_cost',
  'IMPEX Yearly Cost',
  'IsUpfront * (Year == 1 ? FinalCost : 0) + (1 - IsUpfront) * (Year <= DepreciationYears ? (BaseCost / DepreciationYears) : 0)',
  'currency',
  'impex',
  'Calculates the cost for a specific year based on charging method (upfront in year 1, or amortized)',
  '[
    {
      "key": "IsUpfront",
      "source": "context",
      "field": "IsUpfront",
      "description": "Numeric flag: 1 if charging method is upfront, 0 if amortise"
    },
    {
      "key": "Year",
      "source": "context",
      "field": "Year",
      "description": "Current calculation year"
    },
    {
      "key": "FinalCost",
      "source": "calculated",
      "formula_reference": "impex_final_cost",
      "description": "Final cost with margin/markup"
    },
    {
      "key": "BaseCost",
      "source": "calculated",
      "formula_reference": "impex_base_cost",
      "description": "Base cost for amortization"
    },
    {
      "key": "DepreciationYears",
      "source": "context",
      "field": "DepreciationYears",
      "description": "Years to spread cost over"
    }
  ]'::jsonb,
  ARRAY['impex_base_cost', 'impex_final_cost'],
  true,
  1,
  NOW(),
  NOW()
);