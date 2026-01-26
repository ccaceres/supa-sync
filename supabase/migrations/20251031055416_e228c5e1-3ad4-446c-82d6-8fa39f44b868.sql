-- Fix OPEX driver quantity calculation bug
-- The issue: When a driver is present, we were incorrectly multiplying by base_quantity,
-- causing quantity values to be squared (e.g., 338,540 × 338,540 = 114 billion)

CREATE OR REPLACE FUNCTION public.bulk_calculate_opex_costs(p_model_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
    opex_record RECORD;
    num_years INTEGER := 10;
    year_idx INTEGER;
    driver_values NUMERIC[] := '{}';
    calculated_quantities NUMERIC[] := '{}';
    base_costs NUMERIC[] := '{}';
    final_costs NUMERIC[] := '{}';
    driver_multiplier NUMERIC;
    average_cost NUMERIC;
BEGIN
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
                -- FIX: When driver exists, use ONLY driver_value × driver_ratio
                -- Do NOT multiply by base_quantity (that would square the quantity!)
                IF driver_value IS NOT NULL THEN
                    calculated_quantity := driver_value * driver_multiplier;
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
        
        -- Zero out years beyond number_of_years if specified
        IF opex_record.number_of_years IS NOT NULL AND opex_record.number_of_years < num_years THEN
            FOR year_idx IN (opex_record.number_of_years + 1)..num_years LOOP
                final_costs[year_idx] := 0;
                calculated_quantities[year_idx] := 0;
            END LOOP;
        END IF;
        
        -- Update the opex_lines record with calculated values
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
            cost_year_1 = final_costs[1],
            cost_year_2 = final_costs[2],
            cost_year_3 = final_costs[3],
            cost_year_4 = final_costs[4],
            cost_year_5 = final_costs[5],
            cost_year_6 = final_costs[6],
            cost_year_7 = final_costs[7],
            cost_year_8 = final_costs[8],
            cost_year_9 = final_costs[9],
            cost_year_10 = final_costs[10],
            updated_at = NOW()
        WHERE id = opex_record.id;
    END LOOP;
END;
$function$;