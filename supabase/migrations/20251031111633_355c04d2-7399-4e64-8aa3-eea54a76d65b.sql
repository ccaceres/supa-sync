-- Fix CAPEX depreciation to start year AFTER investment (Option B)
CREATE OR REPLACE FUNCTION update_capex_depreciation()
RETURNS TRIGGER AS $$
DECLARE
  base_cost NUMERIC;
  salvage_val NUMERIC;
  annual_deprec NUMERIC;
  investment_yr INTEGER;
  deprec_yrs INTEGER;
BEGIN
  -- Calculate base cost from SUM of all investment year columns
  base_cost := COALESCE(NEW.investment_year_1, 0) + COALESCE(NEW.investment_year_2, 0) +
               COALESCE(NEW.investment_year_3, 0) + COALESCE(NEW.investment_year_4, 0) +
               COALESCE(NEW.investment_year_5, 0) + COALESCE(NEW.investment_year_6, 0) +
               COALESCE(NEW.investment_year_7, 0) + COALESCE(NEW.investment_year_8, 0) +
               COALESCE(NEW.investment_year_9, 0) + COALESCE(NEW.investment_year_10, 0) +
               COALESCE(NEW.investment_year_11, 0) + COALESCE(NEW.investment_year_12, 0) +
               COALESCE(NEW.investment_year_13, 0) + COALESCE(NEW.investment_year_14, 0) +
               COALESCE(NEW.investment_year_15, 0) + COALESCE(NEW.investment_year_16, 0) +
               COALESCE(NEW.investment_year_17, 0) + COALESCE(NEW.investment_year_18, 0) +
               COALESCE(NEW.investment_year_19, 0) + COALESCE(NEW.investment_year_20, 0);
  
  -- If no investment years are set, fall back to quantity * unit_cost
  IF base_cost = 0 THEN
    base_cost := COALESCE(NEW.quantity, 0) * COALESCE(NEW.unit_cost, 0);
  END IF;
  
  salvage_val := base_cost * (COALESCE(NEW.salvage_percentage, 0) / 100.0);
  deprec_yrs := COALESCE(NEW.depreciation_years, 5);
  annual_deprec := CASE 
    WHEN deprec_yrs > 0 THEN (base_cost - salvage_val) / deprec_yrs
    ELSE 0
  END;
  
  -- Find earliest year with investment
  investment_yr := COALESCE(NEW.investment_year, 1);
  IF COALESCE(NEW.investment_year_1, 0) > 0 THEN investment_yr := 1;
  ELSIF COALESCE(NEW.investment_year_2, 0) > 0 THEN investment_yr := 2;
  ELSIF COALESCE(NEW.investment_year_3, 0) > 0 THEN investment_yr := 3;
  ELSIF COALESCE(NEW.investment_year_4, 0) > 0 THEN investment_yr := 4;
  ELSIF COALESCE(NEW.investment_year_5, 0) > 0 THEN investment_yr := 5;
  ELSIF COALESCE(NEW.investment_year_6, 0) > 0 THEN investment_yr := 6;
  ELSIF COALESCE(NEW.investment_year_7, 0) > 0 THEN investment_yr := 7;
  ELSIF COALESCE(NEW.investment_year_8, 0) > 0 THEN investment_yr := 8;
  ELSIF COALESCE(NEW.investment_year_9, 0) > 0 THEN investment_yr := 9;
  ELSIF COALESCE(NEW.investment_year_10, 0) > 0 THEN investment_yr := 10;
  ELSIF COALESCE(NEW.investment_year_11, 0) > 0 THEN investment_yr := 11;
  ELSIF COALESCE(NEW.investment_year_12, 0) > 0 THEN investment_yr := 12;
  ELSIF COALESCE(NEW.investment_year_13, 0) > 0 THEN investment_yr := 13;
  ELSIF COALESCE(NEW.investment_year_14, 0) > 0 THEN investment_yr := 14;
  ELSIF COALESCE(NEW.investment_year_15, 0) > 0 THEN investment_yr := 15;
  ELSIF COALESCE(NEW.investment_year_16, 0) > 0 THEN investment_yr := 16;
  ELSIF COALESCE(NEW.investment_year_17, 0) > 0 THEN investment_yr := 17;
  ELSIF COALESCE(NEW.investment_year_18, 0) > 0 THEN investment_yr := 18;
  ELSIF COALESCE(NEW.investment_year_19, 0) > 0 THEN investment_yr := 19;
  ELSIF COALESCE(NEW.investment_year_20, 0) > 0 THEN investment_yr := 20;
  END IF;
  
  -- Depreciation starts year AFTER investment (Option B)
  -- For investment in year X, depreciation runs from year X+1 to X+deprec_yrs
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