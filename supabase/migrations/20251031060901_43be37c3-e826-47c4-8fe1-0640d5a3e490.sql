-- Fix OPEX calculation issues: Zero out years 11-20 and make num_years dynamic
-- This fixes the issue where years 11+ show unexpected values

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
    driver_values NUMERIC[] := '{}';
    calculated_quantities NUMERIC[] := '{}';
    base_costs NUMERIC[] := '{}';
    final_costs NUMERIC[] := '{}';
    driver_multiplier NUMERIC;
    average_cost NUMERIC;
BEGIN
    -- Fetch contract_years from model parameters dynamically
    SELECT COALESCE((data->>'contract_years')::INTEGER, 10) 
    INTO num_years
    FROM model_parameters 
    WHERE model_id = p_model_id 
    AND parameter_type = 'basic'
    LIMIT 1;
    
    -- If not found, default to 10
    IF num_years IS NULL THEN
        num_years := 10;
    END IF;
    
    FOR opex_record IN 
        SELECT * FROM opex_lines WHERE model_id = p_model_id
    LOOP
        -- Reset arrays for each record
        driver_values := '{}';
        calculated_quantities := '{}';
        base_costs := '{}';
        final_costs := '{}';
        driver_multiplier := COALESCE(opex_record.driver_ratio, 1);
        
        -- Calculate quantities and costs for each year
        FOR year_idx IN 1..num_years LOOP
            DECLARE
                driver_value NUMERIC;
                base_quantity_value NUMERIC;
                calculated_quantity NUMERIC;
                base_cost NUMERIC;
            BEGIN
                -- Start with base_quantity
                base_quantity_value := COALESCE(opex_record.base_quantity, 1);
                
                -- Get driver value for this year if driver is linked
                driver_value := NULL;
                IF opex_record.driver_id IS NOT NULL THEN
                    -- Check volumes table
                    EXECUTE format('SELECT year_%s FROM volumes WHERE id = $1', year_idx)
                    INTO driver_value
                    USING opex_record.driver_id;
                    
                    -- If not found, check exempt_positions
                    IF driver_value IS NULL THEN
                        EXECUTE format('SELECT fte_year_%s FROM exempt_positions WHERE id = $1', year_idx)
                        INTO driver_value
                        USING opex_record.driver_id;
                    END IF;
                    
                    -- If not found, check nonexempt_positions
                    IF driver_value IS NULL THEN
                        EXECUTE format('SELECT fte_year_%s FROM nonexempt_positions WHERE id = $1', year_idx)
                        INTO driver_value
                        USING opex_record.driver_id;
                    END IF;
                END IF;
                
                -- Calculate quantity based on driver
                IF driver_value IS NOT NULL THEN
                    calculated_quantity := driver_value * driver_multiplier;
                ELSE
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
        
        -- Apply treat_as_asset logic (averaging) or inflation (escalation)
        IF opex_record.treat_as_asset THEN
            -- Calculate average cost across all years
            average_cost := (
                SELECT AVG(cost) FROM unnest(base_costs) AS cost
            );
            
            -- Set all years to the average
            FOR year_idx IN 1..num_years LOOP
                final_costs := array_append(final_costs, average_cost);
            END LOOP;
        ELSE
            -- Apply inflation escalation year over year
            FOR year_idx IN 1..num_years LOOP
                final_costs := array_append(
                    final_costs, 
                    base_costs[year_idx] * POWER(1 + COALESCE(opex_record.inflation, 0.03), year_idx - 1)
                );
            END LOOP;
        END IF;
        
        -- Update the opex_lines record with calculated values
        -- Years 1-10 (or contract_years) get calculated values
        -- Years 11-20 explicitly set to zero to clear old data
        UPDATE opex_lines SET
            quantity_year_1 = COALESCE(calculated_quantities[1], 0),
            quantity_year_2 = COALESCE(calculated_quantities[2], 0),
            quantity_year_3 = COALESCE(calculated_quantities[3], 0),
            quantity_year_4 = COALESCE(calculated_quantities[4], 0),
            quantity_year_5 = COALESCE(calculated_quantities[5], 0),
            quantity_year_6 = COALESCE(calculated_quantities[6], 0),
            quantity_year_7 = COALESCE(calculated_quantities[7], 0),
            quantity_year_8 = COALESCE(calculated_quantities[8], 0),
            quantity_year_9 = COALESCE(calculated_quantities[9], 0),
            quantity_year_10 = COALESCE(calculated_quantities[10], 0),
            quantity_year_11 = 0,
            quantity_year_12 = 0,
            quantity_year_13 = 0,
            quantity_year_14 = 0,
            quantity_year_15 = 0,
            quantity_year_16 = 0,
            quantity_year_17 = 0,
            quantity_year_18 = 0,
            quantity_year_19 = 0,
            quantity_year_20 = 0,
            cost_year_1 = COALESCE(final_costs[1], 0),
            cost_year_2 = COALESCE(final_costs[2], 0),
            cost_year_3 = COALESCE(final_costs[3], 0),
            cost_year_4 = COALESCE(final_costs[4], 0),
            cost_year_5 = COALESCE(final_costs[5], 0),
            cost_year_6 = COALESCE(final_costs[6], 0),
            cost_year_7 = COALESCE(final_costs[7], 0),
            cost_year_8 = COALESCE(final_costs[8], 0),
            cost_year_9 = COALESCE(final_costs[9], 0),
            cost_year_10 = COALESCE(final_costs[10], 0),
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