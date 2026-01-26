-- Fix CAPEX depreciation calculation logic
-- Update existing data to use 1-based investment years
UPDATE capex_lines 
SET investment_year = 1, updated_at = NOW()
WHERE investment_year = 0;

-- Recreate function with corrected depreciation logic
CREATE OR REPLACE FUNCTION bulk_calculate_capex_costs(p_model_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  capex_record RECORD;
  base_cost NUMERIC;
  salvage_val NUMERIC;
  annual_deprec NUMERIC;
  investment_yr INTEGER;
  deprec_yrs INTEGER;
BEGIN
  FOR capex_record IN 
    SELECT * FROM capex_lines WHERE model_id = p_model_id
  LOOP
    -- Calculate base values
    base_cost := COALESCE(capex_record.quantity, 0) * COALESCE(capex_record.unit_cost, 0);
    salvage_val := base_cost * (COALESCE(capex_record.salvage_percentage, 0) / 100.0);
    deprec_yrs := COALESCE(capex_record.depreciation_years, 5);
    annual_deprec := CASE 
      WHEN deprec_yrs > 0 THEN (base_cost - salvage_val) / deprec_yrs
      ELSE 0
    END;
    -- Use 1 as minimum investment year (not 0)
    investment_yr := GREATEST(COALESCE(capex_record.investment_year, 1), 1);
    
    -- Update cost_year_X columns with correct depreciation logic
    UPDATE capex_lines SET
      total_investment = base_cost,
      cost_year_1 = CASE WHEN 1 >= investment_yr AND (1 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_2 = CASE WHEN 2 >= investment_yr AND (2 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_3 = CASE WHEN 3 >= investment_yr AND (3 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_4 = CASE WHEN 4 >= investment_yr AND (4 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_5 = CASE WHEN 5 >= investment_yr AND (5 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_6 = CASE WHEN 6 >= investment_yr AND (6 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_7 = CASE WHEN 7 >= investment_yr AND (7 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_8 = CASE WHEN 8 >= investment_yr AND (8 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_9 = CASE WHEN 9 >= investment_yr AND (9 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_10 = CASE WHEN 10 >= investment_yr AND (10 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_11 = CASE WHEN 11 >= investment_yr AND (11 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_12 = CASE WHEN 12 >= investment_yr AND (12 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_13 = CASE WHEN 13 >= investment_yr AND (13 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_14 = CASE WHEN 14 >= investment_yr AND (14 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_15 = CASE WHEN 15 >= investment_yr AND (15 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_16 = CASE WHEN 16 >= investment_yr AND (16 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_17 = CASE WHEN 17 >= investment_yr AND (17 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_18 = CASE WHEN 18 >= investment_yr AND (18 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_19 = CASE WHEN 19 >= investment_yr AND (19 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_20 = CASE WHEN 20 >= investment_yr AND (20 - investment_yr) < deprec_yrs THEN annual_deprec ELSE 0 END,
      updated_at = NOW()
    WHERE id = capex_record.id;
  END LOOP;
END;
$$;