-- Function to automatically update investment_year_X columns based on investment_year field
CREATE OR REPLACE FUNCTION update_capex_investment_years()
RETURNS TRIGGER AS $$
BEGIN
  -- Clear all investment year columns first
  NEW.investment_year_1 := 0;
  NEW.investment_year_2 := 0;
  NEW.investment_year_3 := 0;
  NEW.investment_year_4 := 0;
  NEW.investment_year_5 := 0;
  NEW.investment_year_6 := 0;
  NEW.investment_year_7 := 0;
  NEW.investment_year_8 := 0;
  NEW.investment_year_9 := 0;
  NEW.investment_year_10 := 0;
  NEW.investment_year_11 := 0;
  NEW.investment_year_12 := 0;
  NEW.investment_year_13 := 0;
  NEW.investment_year_14 := 0;
  NEW.investment_year_15 := 0;
  NEW.investment_year_16 := 0;
  NEW.investment_year_17 := 0;
  NEW.investment_year_18 := 0;
  NEW.investment_year_19 := 0;
  NEW.investment_year_20 := 0;
  
  -- Set the investment in the correct year (1-based indexing)
  CASE GREATEST(COALESCE(NEW.investment_year, 1), 1)
    WHEN 1 THEN NEW.investment_year_1 := NEW.total_investment;
    WHEN 2 THEN NEW.investment_year_2 := NEW.total_investment;
    WHEN 3 THEN NEW.investment_year_3 := NEW.total_investment;
    WHEN 4 THEN NEW.investment_year_4 := NEW.total_investment;
    WHEN 5 THEN NEW.investment_year_5 := NEW.total_investment;
    WHEN 6 THEN NEW.investment_year_6 := NEW.total_investment;
    WHEN 7 THEN NEW.investment_year_7 := NEW.total_investment;
    WHEN 8 THEN NEW.investment_year_8 := NEW.total_investment;
    WHEN 9 THEN NEW.investment_year_9 := NEW.total_investment;
    WHEN 10 THEN NEW.investment_year_10 := NEW.total_investment;
    WHEN 11 THEN NEW.investment_year_11 := NEW.total_investment;
    WHEN 12 THEN NEW.investment_year_12 := NEW.total_investment;
    WHEN 13 THEN NEW.investment_year_13 := NEW.total_investment;
    WHEN 14 THEN NEW.investment_year_14 := NEW.total_investment;
    WHEN 15 THEN NEW.investment_year_15 := NEW.total_investment;
    WHEN 16 THEN NEW.investment_year_16 := NEW.total_investment;
    WHEN 17 THEN NEW.investment_year_17 := NEW.total_investment;
    WHEN 18 THEN NEW.investment_year_18 := NEW.total_investment;
    WHEN 19 THEN NEW.investment_year_19 := NEW.total_investment;
    WHEN 20 THEN NEW.investment_year_20 := NEW.total_investment;
    ELSE NULL;
  END CASE;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to automatically update cost_year_X (depreciation) columns
CREATE OR REPLACE FUNCTION update_capex_depreciation()
RETURNS TRIGGER AS $$
DECLARE
  base_cost NUMERIC;
  salvage_val NUMERIC;
  annual_deprec NUMERIC;
  investment_yr INTEGER;
  deprec_yrs INTEGER;
BEGIN
  -- Calculate base values
  base_cost := COALESCE(NEW.quantity, 0) * COALESCE(NEW.unit_cost, 0);
  salvage_val := base_cost * (COALESCE(NEW.salvage_percentage, 0) / 100.0);
  deprec_yrs := COALESCE(NEW.depreciation_years, 5);
  annual_deprec := CASE 
    WHEN deprec_yrs > 0 THEN (base_cost - salvage_val) / deprec_yrs
    ELSE 0
  END;
  investment_yr := GREATEST(COALESCE(NEW.investment_year, 1), 1);
  
  -- Update each year's depreciation (depreciation starts the year AFTER investment)
  NEW.cost_year_1 := CASE WHEN 1 > investment_yr AND (1 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_2 := CASE WHEN 2 > investment_yr AND (2 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_3 := CASE WHEN 3 > investment_yr AND (3 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_4 := CASE WHEN 4 > investment_yr AND (4 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_5 := CASE WHEN 5 > investment_yr AND (5 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_6 := CASE WHEN 6 > investment_yr AND (6 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_7 := CASE WHEN 7 > investment_yr AND (7 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_8 := CASE WHEN 8 > investment_yr AND (8 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_9 := CASE WHEN 9 > investment_yr AND (9 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_10 := CASE WHEN 10 > investment_yr AND (10 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_11 := CASE WHEN 11 > investment_yr AND (11 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_12 := CASE WHEN 12 > investment_yr AND (12 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_13 := CASE WHEN 13 > investment_yr AND (13 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_14 := CASE WHEN 14 > investment_yr AND (14 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_15 := CASE WHEN 15 > investment_yr AND (15 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_16 := CASE WHEN 16 > investment_yr AND (16 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_17 := CASE WHEN 17 > investment_yr AND (17 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_18 := CASE WHEN 18 > investment_yr AND (18 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_19 := CASE WHEN 19 > investment_yr AND (19 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  NEW.cost_year_20 := CASE WHEN 20 > investment_yr AND (20 - investment_yr) <= deprec_yrs THEN annual_deprec ELSE 0 END;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for investment year columns
DROP TRIGGER IF EXISTS trigger_update_capex_investment_years ON capex_lines;
CREATE TRIGGER trigger_update_capex_investment_years
  BEFORE INSERT OR UPDATE OF investment_year, total_investment
  ON capex_lines
  FOR EACH ROW
  EXECUTE FUNCTION update_capex_investment_years();

-- Create trigger for depreciation columns
DROP TRIGGER IF EXISTS trigger_update_capex_depreciation ON capex_lines;
CREATE TRIGGER trigger_update_capex_depreciation
  BEFORE INSERT OR UPDATE OF quantity, unit_cost, investment_year, depreciation_years, salvage_percentage
  ON capex_lines
  FOR EACH ROW
  EXECUTE FUNCTION update_capex_depreciation();