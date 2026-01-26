-- Fix bulk_calculate_impex_costs to only update existing columns (cost_year_1 through cost_year_10)
CREATE OR REPLACE FUNCTION public.bulk_calculate_impex_costs(p_model_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
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
        updated_at = NOW()
      WHERE id = impex_record.id;
    END IF;
  END LOOP;
END;
$function$;