-- One-time cleanup: Clear OPEX costs and quantities beyond contract years
-- This fixes legacy data where Year 11+ had costs despite contract being shorter

UPDATE opex_lines ol
SET 
  cost_year_11 = 0, cost_year_12 = 0, cost_year_13 = 0, cost_year_14 = 0, cost_year_15 = 0,
  cost_year_16 = 0, cost_year_17 = 0, cost_year_18 = 0, cost_year_19 = 0, cost_year_20 = 0,
  quantity_year_11 = 0, quantity_year_12 = 0, quantity_year_13 = 0, quantity_year_14 = 0, quantity_year_15 = 0,
  quantity_year_16 = 0, quantity_year_17 = 0, quantity_year_18 = 0, quantity_year_19 = 0, quantity_year_20 = 0
FROM model_parameters mp
WHERE 
  ol.model_id = mp.model_id 
  AND mp.parameter_type = 'basic'
  AND (mp.data->>'contract_years')::int < 11;

-- Verification comment: After this runs, all OPEX lines for models with contract_years < 11 
-- should have zero costs and quantities for years 11-20