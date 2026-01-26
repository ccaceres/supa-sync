-- Update bulk_calculate_opex_costs to handle treat_as_asset and auto-trigger site allocation
CREATE OR REPLACE FUNCTION public.bulk_calculate_opex_costs(p_model_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
    opex_record RECORD;
    driver_value NUMERIC;
    calculated_quantity NUMERIC;
    base_cost NUMERIC;
    average_cost NUMERIC;
    total_cost_over_years NUMERIC;
    num_years INTEGER := 20;
    year_idx INTEGER;
BEGIN
    -- Update all OPEX lines for the given model
    FOR opex_record IN 
        SELECT * FROM opex_lines 
        WHERE model_id = p_model_id
        AND COALESCE(is_site_allocation, false) = false  -- Exclude site allocation line
    LOOP
        -- Get driver value if driver is linked
        driver_value := NULL;
        IF opex_record.driver_id IS NOT NULL THEN
            -- Check volumes table
            SELECT year_1 INTO driver_value 
            FROM volumes 
            WHERE id = opex_record.driver_id;
            
            -- If not found in volumes, check salary_roles
            IF driver_value IS NULL THEN
                SELECT fte_year_1 INTO driver_value 
                FROM salary_roles 
                WHERE id = opex_record.driver_id;
            END IF;
            
            -- If not found in salary_roles, check direct_roles
            IF driver_value IS NULL THEN
                SELECT hours_year_1 / 2080.0 INTO driver_value 
                FROM direct_roles 
                WHERE id = opex_record.driver_id;
            END IF;
        END IF;
        
        -- Calculate quantity based on driver or use base_quantity
        IF driver_value IS NOT NULL THEN
            calculated_quantity := driver_value * COALESCE(opex_record.driver_ratio, 1);
        ELSE
            calculated_quantity := COALESCE(opex_record.base_quantity, 1);
        END IF;
        
        -- Calculate base cost
        base_cost := COALESCE(opex_record.cpu, 0) * calculated_quantity;
        
        -- Check if we should treat as asset (average costs)
        IF COALESCE(opex_record.treat_as_asset, false) = true THEN
            -- Calculate total cost over all years with inflation
            total_cost_over_years := 0;
            FOR year_idx IN 1..num_years LOOP
                total_cost_over_years := total_cost_over_years + 
                    (base_cost * POWER(1 + COALESCE(opex_record.inflation, 0.03), year_idx - 1));
            END LOOP;
            
            -- Calculate average cost
            average_cost := total_cost_over_years / num_years;
            
            -- Set the same average cost for all years
            UPDATE opex_lines 
            SET 
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
            -- Standard escalating costs with inflation
            UPDATE opex_lines 
            SET 
                cost_year_1 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 0),
                cost_year_2 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 1),
                cost_year_3 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 2),
                cost_year_4 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 3),
                cost_year_5 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 4),
                cost_year_6 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 5),
                cost_year_7 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 6),
                cost_year_8 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 7),
                cost_year_9 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 8),
                cost_year_10 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 9),
                cost_year_11 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 10),
                cost_year_12 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 11),
                cost_year_13 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 12),
                cost_year_14 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 13),
                cost_year_15 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 14),
                cost_year_16 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 15),
                cost_year_17 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 16),
                cost_year_18 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 17),
                cost_year_19 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 18),
                cost_year_20 = base_cost * POWER(1 + COALESCE(inflation, 0.03), 19),
                updated_at = NOW()
            WHERE id = opex_record.id;
        END IF;
    END LOOP;
    
    -- After calculating all OPEX costs, automatically update site allocation
    PERFORM update_site_allocation_costs(p_model_id);
END;
$function$;