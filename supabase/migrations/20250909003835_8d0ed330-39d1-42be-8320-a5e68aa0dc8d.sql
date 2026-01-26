-- Add trigger to automatically calculate total_investment for CAPEX items
CREATE OR REPLACE FUNCTION public.calculate_capex_total_investment()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
    -- Calculate total investment based on quantity and unit cost
    NEW.total_investment = COALESCE(NEW.quantity, 0) * COALESCE(NEW.unit_cost, 0);
    
    RETURN NEW;
END;
$$;

-- Create trigger for INSERT and UPDATE operations
DROP TRIGGER IF EXISTS trigger_calculate_capex_total_investment ON capex_lines;
CREATE TRIGGER trigger_calculate_capex_total_investment
    BEFORE INSERT OR UPDATE ON capex_lines
    FOR EACH ROW
    EXECUTE FUNCTION calculate_capex_total_investment();

-- Add function to recalculate CAPEX based on driver values
CREATE OR REPLACE FUNCTION public.update_capex_from_driver(
    p_model_id UUID,
    p_driver_id UUID,
    p_driver_type TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    capex_record RECORD;
    driver_value NUMERIC;
BEGIN
    -- Update all CAPEX items linked to this driver
    FOR capex_record IN 
        SELECT * FROM capex_lines 
        WHERE model_id = p_model_id 
        AND driver_id = p_driver_id
    LOOP
        -- Get current driver value for year 1 (can be extended for multi-year)
        CASE p_driver_type
            WHEN 'volume' THEN
                SELECT year_1 INTO driver_value 
                FROM volumes 
                WHERE id = p_driver_id;
            WHEN 'salary_role' THEN
                SELECT fte_year_1 INTO driver_value 
                FROM salary_roles 
                WHERE id = p_driver_id;
            WHEN 'direct_role' THEN
                SELECT hours_year_1 / 2080.0 INTO driver_value 
                FROM direct_roles 
                WHERE id = p_driver_id;
        END CASE;
        
        -- Update quantity based on driver value and ratio
        IF driver_value IS NOT NULL THEN
            UPDATE capex_lines 
            SET quantity = driver_value * COALESCE(driver_ratio, 1),
                updated_at = NOW()
            WHERE id = capex_record.id;
        END IF;
    END LOOP;
END;
$$;