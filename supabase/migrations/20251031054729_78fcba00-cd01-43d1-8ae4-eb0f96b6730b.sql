-- Fix bulk_calculate_opex_costs to populate quantity_year_X columns
-- Previously it only populated cost_year_X columns, leaving quantities NULL

CREATE OR REPLACE FUNCTION public.bulk_calculate_opex_costs(p_model_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
    opex_record RECORD;
    driver_values NUMERIC[];
    calculated_quantities NUMERIC[];
    base_costs NUMERIC[];
    year_idx INTEGER;
    driver_multiplier NUMERIC;
    average_cost NUMERIC;
    total_cost_over_years NUMERIC;
    num_years INTEGER;
BEGIN
    -- Get contract_years from model parameters (default to 10 if not found)
    -- This allows each model to define its own projection period
    SELECT COALESCE((data->>'contract_years')::INTEGER, 10)
    INTO num_years
    FROM model_parameters
    WHERE model_id = p_model_id
    AND parameter_type = 'basic'
    LIMIT 1;
    
    -- Cap at 20 years maximum (database schema limitation)
    num_years := LEAST(num_years, 20);
    
    -- Process each OPEX line
    FOR opex_record IN 
        SELECT * FROM opex_lines 
        WHERE model_id = p_model_id
        AND COALESCE(is_site_allocation, false) = false
    LOOP
        -- Initialize arrays
        driver_values := ARRAY[]::NUMERIC[];
        calculated_quantities := ARRAY[]::NUMERIC[];
        base_costs := ARRAY[]::NUMERIC[];
        
        -- Get driver multiplier
        driver_multiplier := COALESCE(opex_record.driver_ratio, 1);
        
        -- Calculate quantities and costs for each year
        FOR year_idx IN 1..num_years LOOP
            DECLARE
                driver_value NUMERIC;
                quantity_value NUMERIC;
                calculated_quantity NUMERIC;
                base_cost NUMERIC;
            BEGIN
                -- Get quantity for this year from quantity_year_X column
                EXECUTE format('SELECT quantity_year_%s FROM opex_lines WHERE id = $1', year_idx)
                INTO quantity_value
                USING opex_record.id;
                
                -- Default to base_quantity if quantity_year is NULL
                quantity_value := COALESCE(quantity_value, opex_record.base_quantity, 1);
                
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
                
                -- Calculate quantity based on driver or use quantity_year value
                IF driver_value IS NOT NULL THEN
                    calculated_quantity := driver_value * driver_multiplier * quantity_value;
                ELSE
                    calculated_quantity := quantity_value;
                END IF;
                
                -- Calculate base cost for this year
                base_cost := COALESCE(opex_record.cpu, 0) * calculated_quantity;
                
                -- Store in arrays
                driver_values := array_append(driver_values, driver_value);
                calculated_quantities := array_append(calculated_quantities, calculated_quantity);
                base_costs := array_append(base_costs, base_cost);
            END;
        END LOOP;
        
        -- Zero out years beyond contract period
        FOR year_idx IN num_years + 1..20 LOOP
            calculated_quantities := array_append(calculated_quantities, 0);
            base_costs := array_append(base_costs, 0);
        END LOOP;
        
        -- Apply inflation and update BOTH cost AND quantity columns
        IF COALESCE(opex_record.treat_as_asset, false) = true THEN
            -- Calculate average cost over all years with inflation
            total_cost_over_years := 0;
            FOR year_idx IN 1..num_years LOOP
                total_cost_over_years := total_cost_over_years + 
                    (base_costs[year_idx] * POWER(1 + COALESCE(opex_record.inflation, 0.03), year_idx - 1));
            END LOOP;
            
            average_cost := total_cost_over_years / num_years;
            
            -- Set same average cost for all years, populate quantities
            UPDATE opex_lines 
            SET 
                -- Update quantity columns
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
                quantity_year_11 = calculated_quantities[11],
                quantity_year_12 = calculated_quantities[12],
                quantity_year_13 = calculated_quantities[13],
                quantity_year_14 = calculated_quantities[14],
                quantity_year_15 = calculated_quantities[15],
                quantity_year_16 = calculated_quantities[16],
                quantity_year_17 = calculated_quantities[17],
                quantity_year_18 = calculated_quantities[18],
                quantity_year_19 = calculated_quantities[19],
                quantity_year_20 = calculated_quantities[20],
                -- Update cost columns
                cost_year_1 = average_cost,
                cost_year_2 = average_cost,
                cost_year_3 = average_cost,
                cost_year_4 = average_cost,
                cost_year_5 = average_cost,
                cost_year_6 = average_cost,
                cost_year_7 = average_cost,
                cost_year_8 = average_cost,
                cost_year_9 = average_cost,
                cost_year_10 = average_cost,
                cost_year_11 = average_cost,
                cost_year_12 = average_cost,
                cost_year_13 = average_cost,
                cost_year_14 = average_cost,
                cost_year_15 = average_cost,
                cost_year_16 = average_cost,
                cost_year_17 = average_cost,
                cost_year_18 = average_cost,
                cost_year_19 = average_cost,
                cost_year_20 = average_cost,
                updated_at = NOW()
            WHERE id = opex_record.id;
        ELSE
            -- Apply escalating costs with inflation, populate quantities
            UPDATE opex_lines 
            SET 
                -- Update quantity columns
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
                quantity_year_11 = calculated_quantities[11],
                quantity_year_12 = calculated_quantities[12],
                quantity_year_13 = calculated_quantities[13],
                quantity_year_14 = calculated_quantities[14],
                quantity_year_15 = calculated_quantities[15],
                quantity_year_16 = calculated_quantities[16],
                quantity_year_17 = calculated_quantities[17],
                quantity_year_18 = calculated_quantities[18],
                quantity_year_19 = calculated_quantities[19],
                quantity_year_20 = calculated_quantities[20],
                -- Update cost columns
                cost_year_1 = base_costs[1] * POWER(1 + COALESCE(inflation, 0.03), 0),
                cost_year_2 = base_costs[2] * POWER(1 + COALESCE(inflation, 0.03), 1),
                cost_year_3 = base_costs[3] * POWER(1 + COALESCE(inflation, 0.03), 2),
                cost_year_4 = base_costs[4] * POWER(1 + COALESCE(inflation, 0.03), 3),
                cost_year_5 = base_costs[5] * POWER(1 + COALESCE(inflation, 0.03), 4),
                cost_year_6 = base_costs[6] * POWER(1 + COALESCE(inflation, 0.03), 5),
                cost_year_7 = base_costs[7] * POWER(1 + COALESCE(inflation, 0.03), 6),
                cost_year_8 = base_costs[8] * POWER(1 + COALESCE(inflation, 0.03), 7),
                cost_year_9 = base_costs[9] * POWER(1 + COALESCE(inflation, 0.03), 8),
                cost_year_10 = base_costs[10] * POWER(1 + COALESCE(inflation, 0.03), 9),
                cost_year_11 = base_costs[11] * POWER(1 + COALESCE(inflation, 0.03), 10),
                cost_year_12 = base_costs[12] * POWER(1 + COALESCE(inflation, 0.03), 11),
                cost_year_13 = base_costs[13] * POWER(1 + COALESCE(inflation, 0.03), 12),
                cost_year_14 = base_costs[14] * POWER(1 + COALESCE(inflation, 0.03), 13),
                cost_year_15 = base_costs[15] * POWER(1 + COALESCE(inflation, 0.03), 14),
                cost_year_16 = base_costs[16] * POWER(1 + COALESCE(inflation, 0.03), 15),
                cost_year_17 = base_costs[17] * POWER(1 + COALESCE(inflation, 0.03), 16),
                cost_year_18 = base_costs[18] * POWER(1 + COALESCE(inflation, 0.03), 17),
                cost_year_19 = base_costs[19] * POWER(1 + COALESCE(inflation, 0.03), 18),
                cost_year_20 = base_costs[20] * POWER(1 + COALESCE(inflation, 0.03), 19),
                updated_at = NOW()
            WHERE id = opex_record.id;
        END IF;
    END LOOP;
    
    -- Auto-update site allocation after calculations
    PERFORM update_site_allocation_costs(p_model_id);
END;
$function$;