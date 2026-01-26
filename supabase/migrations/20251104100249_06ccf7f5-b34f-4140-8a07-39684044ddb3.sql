-- Fix library formula templates to use correct variable sources
-- Variables should be sourced from context, not calculated

-- Fix impex_base_cost variables
UPDATE formula_templates 
SET variables = '[
  {"key": "Quantity", "source": "context", "field": "Quantity", "description": "Effective quantity"},
  {"key": "UnitCost", "source": "context", "field": "UnitCost", "description": "Unit cost per item"}
]'::jsonb,
version = version + 1
WHERE formula_key = 'impex_base_cost';

-- Fix impex_final_cost variables  
UPDATE formula_templates
SET variables = '[
  {"key": "BaseCost", "source": "context", "field": "BaseCost", "description": "Base cost from context"},
  {"key": "ChargingTreatment", "source": "context", "field": "ChargingTreatment", "description": "0=Margin, 1=Markup"},
  {"key": "MarginMarkup", "source": "context", "field": "MarginMarkup", "description": "Percentage"}
]'::jsonb,
version = version + 1
WHERE formula_key = 'impex_final_cost';

-- Fix impex_yearly_cost variables
UPDATE formula_templates
SET variables = '[
  {"key": "IsUpfront", "source": "context", "field": "IsUpfront", "description": "1 if upfront, 0 if amortise"},
  {"key": "Year", "source": "context", "field": "Year", "description": "Current year"},
  {"key": "FinalCost", "source": "context", "field": "FinalCost", "description": "Final cost from context"},
  {"key": "BaseCost", "source": "context", "field": "BaseCost", "description": "Base cost from context"},
  {"key": "DepreciationYears", "source": "context", "field": "DepreciationYears", "description": "Amortization period"}
]'::jsonb,
version = version + 1
WHERE formula_key = 'impex_yearly_cost';

-- Log the fix
DO $$
BEGIN
  RAISE NOTICE 'Fixed library IMPEX formula variable definitions to use context source';
END $$;