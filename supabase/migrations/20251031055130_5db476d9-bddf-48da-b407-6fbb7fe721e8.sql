-- Fix OPEX quantity calculation logic to eliminate circular dependency
CREATE OR REPLACE FUNCTION public.bulk_calculate_opex_costs(p_model_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  opex_record RECORD;
  num_years INTEGER;
  year_idx INTEGER;
  inflation_rate NUMERIC;
  driver_multiplier NUMERIC;
  treat_as_asset BOOLEAN;
  
  -- Arrays to store calculated values
  driver_values NUMERIC[];
  calculated_quantities NUMERIC[];
  base_costs NUMERIC[];
  escalated_costs NUMERIC[];
  
  -- For average calculation
  total_cost NUMERIC;
  avg_cost NUMERIC;
BEGIN
  -- Get number of years from finance parameters
  SELECT COALESCE((data->>'contract_years')::INTEGER, 10)
  INTO num_years
  FROM model_parameters
  WHERE model_id = p_model_id AND parameter_type = 'finance';
  
  -- Cap at 10 years
  num_years := LEAST(num_years, 10);
  
  -- Process each OPEX line
  FOR opex_record IN 
    SELECT * FROM opex_lines WHERE model_id = p_model_id
  LOOP
    -- Reset arrays
    driver_values := ARRAY[]::NUMERIC[];
    calculated_quantities := ARRAY[]::NUMERIC[];
    base_costs := ARRAY[]::NUMERIC[];
    escalated_costs := ARRAY[]::NUMERIC[];
    
    -- Get parameters
    inflation_rate := COALESCE(opex_record.inflation, 0.03);
    driver_multiplier := COALESCE(opex_record.driver_ratio, 1);
    treat_as_asset := COALESCE(opex_record.treat_as_asset, false);
    
    -- Calculate quantities and costs for each year
    FOR year_idx IN 1..num_years LOOP
      DECLARE
        driver_value NUMERIC;
        base_quantity_value NUMERIC;
        calculated_quantity NUMERIC;
        base_cost NUMERIC;
      BEGIN
        -- Start with base_quantity (not quantity_year_X)
        base_quantity_value := COALESCE(opex_record.base_quantity, 1);
        
        -- Get driver value for this year if driver is linked
        driver_value := NULL;
        IF opex_record.driver_id IS NOT NULL THEN
          -- Check volumes table
          EXECUTE format('SELECT year_%s FROM volumes WHERE id = $1', year_idx)
          INTO driver_value
          USING opex_record.driver_id;
          
          -- If not found, check salary_roles
          IF driver_value IS NULL THEN
            EXECUTE format('SELECT fte_year_%s FROM salary_roles WHERE id = $1', year_idx)
            INTO driver_value
            USING opex_record.driver_id;
          END IF;
          
          -- If not found, check direct_roles  
          IF driver_value IS NULL THEN
            EXECUTE format('SELECT hours_year_%s / 2080.0 FROM direct_roles WHERE id = $1', year_idx)
            INTO driver_value
            USING opex_record.driver_id;
          END IF;
        END IF;
        
        -- Calculate quantity based on driver
        IF driver_value IS NOT NULL THEN
          -- Multiply: driver_value × driver_ratio × base_quantity
          calculated_quantity := driver_value * driver_multiplier * base_quantity_value;
        ELSE
          -- No driver: use base_quantity directly
          calculated_quantity := base_quantity_value;
        END IF;
        
        -- Calculate base cost for this year (CPU × Quantity)
        base_cost := COALESCE(opex_record.cpu, 0) * calculated_quantity;
        
        -- Store in arrays
        driver_values := array_append(driver_values, driver_value);
        calculated_quantities := array_append(calculated_quantities, calculated_quantity);
        base_costs := array_append(base_costs, base_cost);
      END;
    END LOOP;
    
    -- Apply inflation and treat_as_asset logic
    IF treat_as_asset THEN
      -- Calculate average cost across all years
      total_cost := 0;
      FOR year_idx IN 1..num_years LOOP
        total_cost := total_cost + (base_costs[year_idx] * POWER(1 + inflation_rate, year_idx - 1));
      END LOOP;
      avg_cost := total_cost / num_years;
      
      -- Use average cost for all years
      FOR year_idx IN 1..num_years LOOP
        escalated_costs := array_append(escalated_costs, avg_cost);
      END LOOP;
    ELSE
      -- Apply escalation with inflation
      FOR year_idx IN 1..num_years LOOP
        escalated_costs := array_append(escalated_costs, 
          base_costs[year_idx] * POWER(1 + inflation_rate, year_idx - 1)
        );
      END LOOP;
    END IF;
    
    -- Update the record with calculated values
    UPDATE opex_lines SET
      quantity_year_1 = calculated_quantities[1],
      quantity_year_2 = calculated_quantities[2],
      quantity_year_3 = calculated_quantities[3],
      quantity_year_4 = calculated_quantities[4],
      quantity_year_5 = calculated_quantities[5],
      quantity_year_6 = calculated_quantities[6],
      quantity_year_7 = calculated_quantities[7],
      quantity_year_8 = calculated_quantities[8],
      quantity_year_9 = calculated_quantities[9],
      quantity_year_10 = calculated_quantities[10],
      cost_year_1 = CASE WHEN 1 <= num_years THEN escalated_costs[1] ELSE 0 END,
      cost_year_2 = CASE WHEN 2 <= num_years THEN escalated_costs[2] ELSE 0 END,
      cost_year_3 = CASE WHEN 3 <= num_years THEN escalated_costs[3] ELSE 0 END,
      cost_year_4 = CASE WHEN 4 <= num_years THEN escalated_costs[4] ELSE 0 END,
      cost_year_5 = CASE WHEN 5 <= num_years THEN escalated_costs[5] ELSE 0 END,
      cost_year_6 = CASE WHEN 6 <= num_years THEN escalated_costs[6] ELSE 0 END,
      cost_year_7 = CASE WHEN 7 <= num_years THEN escalated_costs[7] ELSE 0 END,
      cost_year_8 = CASE WHEN 8 <= num_years THEN escalated_costs[8] ELSE 0 END,
      cost_year_9 = CASE WHEN 9 <= num_years THEN escalated_costs[9] ELSE 0 END,
      cost_year_10 = CASE WHEN 10 <= num_years THEN escalated_costs[10] ELSE 0 END,
      cost_year_11 = 0,
      cost_year_12 = 0,
      cost_year_13 = 0,
      cost_year_14 = 0,
      cost_year_15 = 0,
      cost_year_16 = 0,
      cost_year_17 = 0,
      cost_year_18 = 0,
      cost_year_19 = 0,
      cost_year_20 = 0,
      updated_at = NOW()
    WHERE id = opex_record.id;
  END LOOP;
END;
$function$;