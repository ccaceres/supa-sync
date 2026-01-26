-- Allow NULL values for inflation overrides in labex_indirect_labor
ALTER TABLE labex_indirect_labor 
ALTER COLUMN annual_inflation_percentage DROP NOT NULL;

-- Clear inflation overrides for model 03ea8f9a-6921-42ba-b432-400e5f682eff
UPDATE labex_indirect_labor 
SET annual_inflation_percentage = NULL 
WHERE model_id = '03ea8f9a-6921-42ba-b432-400e5f682eff'
AND annual_inflation_percentage IS NOT NULL;