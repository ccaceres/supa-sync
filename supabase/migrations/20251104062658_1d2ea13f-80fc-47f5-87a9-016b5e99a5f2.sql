-- Update impex_yearly_cost formula to use numeric flags instead of string comparisons
-- This fixes the issue where mathjs cannot evaluate string comparisons like ChargingMethod == "upfront"

UPDATE formula_templates 
SET expression = 'IsUpfront * (Year == 1 ? FinalCost : 0) + (1 - IsUpfront) * (Year <= DepreciationYears ? (BaseCost / DepreciationYears) : 0)',
    updated_at = now()
WHERE template_name = 'zulu_standard' 
  AND formula_key = 'impex_yearly_cost';

UPDATE formula_definitions 
SET expression = 'IsUpfront * (Year == 1 ? FinalCost : 0) + (1 - IsUpfront) * (Year <= DepreciationYears ? (BaseCost / DepreciationYears) : 0)',
    updated_at = now()
WHERE model_id = 'b5f7af51-25de-4aff-918d-d6c43f2a6cce' 
  AND formula_key = 'impex_yearly_cost';