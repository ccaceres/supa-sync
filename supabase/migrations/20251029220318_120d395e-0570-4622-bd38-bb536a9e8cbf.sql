-- Add rates_calculated_at timestamp to price_lines table
ALTER TABLE price_lines ADD COLUMN IF NOT EXISTS rates_calculated_at TIMESTAMP WITH TIME ZONE;

-- Create bulk CAPEX calculation function
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
    investment_yr := COALESCE(capex_record.investment_year, 1);
    
    -- Update cost_year_X columns with depreciation values
    UPDATE capex_lines SET
      total_investment = base_cost,
      salvage_value = salvage_val,
      annual_depreciation = annual_deprec,
      cost_year_1 = CASE WHEN 1 >= investment_yr AND 1 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_2 = CASE WHEN 2 >= investment_yr AND 2 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_3 = CASE WHEN 3 >= investment_yr AND 3 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_4 = CASE WHEN 4 >= investment_yr AND 4 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_5 = CASE WHEN 5 >= investment_yr AND 5 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_6 = CASE WHEN 6 >= investment_yr AND 6 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_7 = CASE WHEN 7 >= investment_yr AND 7 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_8 = CASE WHEN 8 >= investment_yr AND 8 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_9 = CASE WHEN 9 >= investment_yr AND 9 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_10 = CASE WHEN 10 >= investment_yr AND 10 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_11 = CASE WHEN 11 >= investment_yr AND 11 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_12 = CASE WHEN 12 >= investment_yr AND 12 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_13 = CASE WHEN 13 >= investment_yr AND 13 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_14 = CASE WHEN 14 >= investment_yr AND 14 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_15 = CASE WHEN 15 >= investment_yr AND 15 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_16 = CASE WHEN 16 >= investment_yr AND 16 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_17 = CASE WHEN 17 >= investment_yr AND 17 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_18 = CASE WHEN 18 >= investment_yr AND 18 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_19 = CASE WHEN 19 >= investment_yr AND 19 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      cost_year_20 = CASE WHEN 20 >= investment_yr AND 20 < investment_yr + deprec_yrs THEN annual_deprec ELSE 0 END,
      updated_at = NOW()
    WHERE id = capex_record.id;
  END LOOP;
END;
$$;

-- Create bulk IMPEX calculation function
CREATE OR REPLACE FUNCTION bulk_calculate_impex_costs(p_model_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  impex_record RECORD;
  base_cost NUMERIC;
  final_cost NUMERIC;
  amortized_cost NUMERIC;
  deprec_yrs INTEGER;
BEGIN
  FOR impex_record IN 
    SELECT * FROM impex_lines WHERE model_id = p_model_id
  LOOP
    base_cost := COALESCE(impex_record.quantity, 0) * COALESCE(impex_record.unit_cost, 0);
    deprec_yrs := COALESCE(impex_record.depreciation_years, 1);
    
    IF impex_record.charging_method = 'upfront' THEN
      -- Calculate upfront cost with margin/markup
      IF impex_record.charging_treatment = 0 THEN -- Margin
        final_cost := CASE 
          WHEN COALESCE(impex_record.margin_markup, 0) < 100 
          THEN base_cost / (1 - COALESCE(impex_record.margin_markup, 0) / 100.0)
          ELSE base_cost
        END;
      ELSE -- Markup
        final_cost := base_cost * (1 + COALESCE(impex_record.margin_markup, 0) / 100.0);
      END IF;
      
      UPDATE impex_lines SET
        total_cost = base_cost,
        total_upfront = final_cost,
        cost_year_1 = final_cost,
        cost_year_2 = 0, cost_year_3 = 0, cost_year_4 = 0, cost_year_5 = 0,
        cost_year_6 = 0, cost_year_7 = 0, cost_year_8 = 0, cost_year_9 = 0, cost_year_10 = 0,
        cost_year_11 = 0, cost_year_12 = 0, cost_year_13 = 0, cost_year_14 = 0, cost_year_15 = 0,
        cost_year_16 = 0, cost_year_17 = 0, cost_year_18 = 0, cost_year_19 = 0, cost_year_20 = 0,
        updated_at = NOW()
      WHERE id = impex_record.id;
      
    ELSIF impex_record.charging_method = 'amortise' THEN
      amortized_cost := CASE 
        WHEN deprec_yrs > 0 THEN base_cost / deprec_yrs
        ELSE base_cost
      END;
      
      UPDATE impex_lines SET
        total_cost = base_cost,
        total_upfront = 0,
        cost_year_1 = CASE WHEN 1 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_2 = CASE WHEN 2 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_3 = CASE WHEN 3 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_4 = CASE WHEN 4 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_5 = CASE WHEN 5 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_6 = CASE WHEN 6 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_7 = CASE WHEN 7 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_8 = CASE WHEN 8 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_9 = CASE WHEN 9 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_10 = CASE WHEN 10 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_11 = CASE WHEN 11 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_12 = CASE WHEN 12 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_13 = CASE WHEN 13 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_14 = CASE WHEN 14 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_15 = CASE WHEN 15 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_16 = CASE WHEN 16 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_17 = CASE WHEN 17 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_18 = CASE WHEN 18 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_19 = CASE WHEN 19 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        cost_year_20 = CASE WHEN 20 <= deprec_yrs THEN amortized_cost ELSE 0 END,
        updated_at = NOW()
      WHERE id = impex_record.id;
    END IF;
  END LOOP;
END;
$$;

-- Create bulk price line rate calculation function
CREATE OR REPLACE FUNCTION bulk_calculate_price_line_rates(
  p_model_id uuid,
  p_price_line_ids uuid[]
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  price_line_record RECORD;
  total_costs NUMERIC[];
  volumes NUMERIC[];
  cost_per_unit NUMERIC;
  final_rate NUMERIC;
  success_count INTEGER := 0;
  failure_count INTEGER := 0;
  errors TEXT[] := '{}';
BEGIN
  FOR price_line_record IN 
    SELECT pl.* 
    FROM price_lines pl
    WHERE pl.model_id = p_model_id 
    AND pl.id = ANY(p_price_line_ids)
  LOOP
    BEGIN
      -- Get volumes from linked volume stream
      SELECT ARRAY[
        COALESCE(year_1, 0), COALESCE(year_2, 0), COALESCE(year_3, 0), COALESCE(year_4, 0), COALESCE(year_5, 0),
        COALESCE(year_6, 0), COALESCE(year_7, 0), COALESCE(year_8, 0), COALESCE(year_9, 0), COALESCE(year_10, 0),
        COALESCE(year_11, 0), COALESCE(year_12, 0), COALESCE(year_13, 0), COALESCE(year_14, 0), COALESCE(year_15, 0),
        COALESCE(year_16, 0), COALESCE(year_17, 0), COALESCE(year_18, 0), COALESCE(year_19, 0), COALESCE(year_20, 0)
      ] INTO volumes
      FROM volumes
      WHERE id = price_line_record.volume_stream_id;
      
      -- Get aggregated costs from cost_price_allocations
      SELECT ARRAY[
        COALESCE(SUM(cost_year_1), 0), COALESCE(SUM(cost_year_2), 0), COALESCE(SUM(cost_year_3), 0),
        COALESCE(SUM(cost_year_4), 0), COALESCE(SUM(cost_year_5), 0), COALESCE(SUM(cost_year_6), 0),
        COALESCE(SUM(cost_year_7), 0), COALESCE(SUM(cost_year_8), 0), COALESCE(SUM(cost_year_9), 0),
        COALESCE(SUM(cost_year_10), 0), COALESCE(SUM(cost_year_11), 0), COALESCE(SUM(cost_year_12), 0),
        COALESCE(SUM(cost_year_13), 0), COALESCE(SUM(cost_year_14), 0), COALESCE(SUM(cost_year_15), 0),
        COALESCE(SUM(cost_year_16), 0), COALESCE(SUM(cost_year_17), 0), COALESCE(SUM(cost_year_18), 0),
        COALESCE(SUM(cost_year_19), 0), COALESCE(SUM(cost_year_20), 0)
      ] INTO total_costs
      FROM cost_price_allocations
      WHERE price_line_id = price_line_record.id;
      
      -- Calculate rates for each year
      FOR year IN 1..20 LOOP
        cost_per_unit := CASE 
          WHEN volumes[year] > 0 THEN total_costs[year] / volumes[year]
          ELSE 0
        END;
        
        IF price_line_record.margin_type = 'Percentage' THEN
          final_rate := CASE 
            WHEN COALESCE(price_line_record.margin_markup_percent, 0) < 100
            THEN cost_per_unit / (1 - COALESCE(price_line_record.margin_markup_percent, 0) / 100.0)
            ELSE cost_per_unit
          END;
        ELSE
          final_rate := cost_per_unit * (1 + COALESCE(price_line_record.margin_markup_percent, 0) / 100.0);
        END IF;
        
        -- Update rate_X column dynamically
        EXECUTE format('UPDATE price_lines SET rate_%s = $1, rates_calculated_at = NOW() WHERE id = $2', year)
        USING final_rate, price_line_record.id;
      END LOOP;
      
      success_count := success_count + 1;
    EXCEPTION WHEN OTHERS THEN
      failure_count := failure_count + 1;
      errors := array_append(errors, format('Price line %s: %s', price_line_record.line_name, SQLERRM));
    END;
  END LOOP;
  
  RETURN jsonb_build_object(
    'success', failure_count = 0,
    'success_count', success_count,
    'failure_count', failure_count,
    'errors', errors
  );
END;
$$;