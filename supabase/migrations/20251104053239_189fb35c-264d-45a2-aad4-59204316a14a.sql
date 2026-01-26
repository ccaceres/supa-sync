-- Create IMPEX Formula Definitions in formula_templates table
-- Following OPEX pattern for consistency

INSERT INTO formula_templates (
  template_name,
  formula_key,
  display_name,
  expression,
  category,
  variables,
  depends_on,
  version,
  is_system,
  result_type,
  result_unit,
  description
) 
SELECT * FROM (VALUES 
  -- Formula 1: Base cost calculation
  (
    'zulu_standard',
    'impex_base_cost',
    'IMPEX Base Cost',
    'Quantity * UnitCost',
    'IMPEX',
    '[
      {"key": "Quantity", "source": "calculated", "description": "Effective quantity (driver-based or manual)"},
      {"key": "UnitCost", "source": "context", "field": "impexUnitCost", "description": "Unit cost per item"}
    ]'::jsonb,
    NULL::text[],
    1,
    true,
    'currency',
    NULL::text,
    'Calculates base implementation cost before margin/markup adjustments'
  ),
  -- Formula 2: Final cost with margin/markup
  (
    'zulu_standard',
    'impex_final_cost',
    'IMPEX Final Cost (with Margin/Markup)',
    'ChargingTreatment == 0 ? (BaseCost / (1 - MarginMarkup / 100)) : (BaseCost * (1 + MarginMarkup / 100))',
    'IMPEX',
    '[
      {"key": "BaseCost", "source": "calculated", "formula_reference": "impex_base_cost", "description": "Base cost before adjustments"},
      {"key": "ChargingTreatment", "source": "context", "field": "impexChargingTreatment", "description": "0 = Margin, 1 = Markup"},
      {"key": "MarginMarkup", "source": "context", "field": "impexMarginMarkup", "description": "Margin or markup percentage"}
    ]'::jsonb,
    ARRAY['impex_base_cost'],
    1,
    true,
    'currency',
    NULL::text,
    'Applies margin (0) or markup (1) to base cost. Margin: Cost/(1-M%), Markup: Cost*(1+M%)'
  ),
  -- Formula 3: Yearly cost distribution
  (
    'zulu_standard',
    'impex_yearly_cost',
    'IMPEX Yearly Cost',
    'ChargingMethod == "upfront" ? (Year == 1 ? FinalCost : 0) : (Year <= DepreciationYears ? (BaseCost / DepreciationYears) : 0)',
    'IMPEX',
    '[
      {"key": "ChargingMethod", "source": "context", "field": "impexChargingMethod", "description": "upfront or amortise"},
      {"key": "Year", "source": "calculated", "description": "Current calculation year"},
      {"key": "FinalCost", "source": "calculated", "formula_reference": "impex_final_cost", "description": "Final cost with margin/markup"},
      {"key": "BaseCost", "source": "calculated", "formula_reference": "impex_base_cost", "description": "Base cost for amortization"},
      {"key": "DepreciationYears", "source": "context", "field": "impexDepreciationYears", "description": "Years to spread cost over"}
    ]'::jsonb,
    ARRAY['impex_base_cost', 'impex_final_cost'],
    1,
    true,
    'currency',
    NULL::text,
    'Distributes cost by charging method. Upfront: all in year 1 with margin/markup. Amortize: spread base cost evenly over depreciation years'
  )
) AS v(template_name, formula_key, display_name, expression, category, variables, depends_on, version, is_system, result_type, result_unit, description)
WHERE NOT EXISTS (
  SELECT 1 FROM formula_templates 
  WHERE formula_templates.template_name = v.template_name 
    AND formula_templates.formula_key = v.formula_key
);
