-- Create function to bulk calculate OPEX costs for a model
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
BEGIN
    -- Update all OPEX lines for the given model
    FOR opex_record IN 
        SELECT * FROM opex_lines 
        WHERE model_id = p_model_id
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
        
        -- Update all cost years with inflation
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
            updated_at = NOW()
        WHERE id = opex_record.id;
    END LOOP;
    
    -- Update site allocation after all calculations
    PERFORM update_site_allocation_costs(p_model_id);
END;
$function$