-- Add missing fields to opex_lines table for comprehensive OPEX management
ALTER TABLE public.opex_lines 
ADD COLUMN driver_id uuid,
ADD COLUMN driver_ratio numeric DEFAULT 1,
ADD COLUMN unit_of_measure character varying DEFAULT 'Units',
ADD COLUMN cpu numeric DEFAULT 0, -- Cost per unit
ADD COLUMN currency character varying DEFAULT 'USD',
ADD COLUMN inflation numeric DEFAULT 0.03,
ADD COLUMN price_imposition integer DEFAULT 0, -- Which pricing stream absorbs this cost (0 = none)
ADD COLUMN treat_as_asset boolean DEFAULT false,
ADD COLUMN protected boolean DEFAULT false,
ADD COLUMN pf_assignment integer DEFAULT 1, -- P&L assignment (1=Direct, 2=Indirect, 3=Overhead, 4=SGA, 21=Site Allocation)
ADD COLUMN equipment_id uuid,
ADD COLUMN row_order integer DEFAULT 0,
ADD COLUMN base_quantity numeric DEFAULT 1,
ADD COLUMN notes text;

-- Add trigger to auto-set row_order
CREATE OR REPLACE FUNCTION public.update_opex_row_order()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = 'public'
AS $function$
BEGIN
    IF NEW.row_order IS NULL OR NEW.row_order = 0 THEN
        SELECT COALESCE(MAX(row_order), 0) + 1 
        INTO NEW.row_order 
        FROM opex_lines 
        WHERE model_id = NEW.model_id;
    END IF;
    RETURN NEW;
END;
$function$;

CREATE TRIGGER update_opex_row_order_trigger
    BEFORE INSERT ON public.opex_lines
    FOR EACH ROW
    EXECUTE FUNCTION public.update_opex_row_order();

-- Create function to calculate OPEX costs with driver scaling and inflation
CREATE OR REPLACE FUNCTION public.calculate_opex_cost(
    p_cpu numeric,
    p_base_quantity numeric,
    p_driver_value numeric DEFAULT NULL,
    p_driver_ratio numeric DEFAULT 1,
    p_inflation numeric DEFAULT 0.03,
    p_year integer DEFAULT 1
) RETURNS numeric
LANGUAGE plpgsql
AS $function$
DECLARE
    quantity numeric;
    inflated_cost numeric;
BEGIN
    -- Calculate quantity based on driver or base quantity
    IF p_driver_value IS NOT NULL THEN
        quantity = p_driver_value * p_driver_ratio;
    ELSE
        quantity = p_base_quantity;
    END IF;
    
    -- Apply inflation over years
    inflated_cost = p_cpu * POWER(1 + p_inflation, p_year - 1);
    
    RETURN quantity * inflated_cost;
END;
$function$;

-- Create function to sync OPEX from driver changes
CREATE OR REPLACE FUNCTION public.update_opex_from_driver(p_model_id uuid, p_driver_id uuid, p_driver_type text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $function$
DECLARE
    opex_record RECORD;
    driver_value NUMERIC;
BEGIN
    -- Update all OPEX items linked to this driver
    FOR opex_record IN 
        SELECT * FROM opex_lines 
        WHERE model_id = p_model_id 
        AND driver_id = p_driver_id
    LOOP
        -- Get current driver value for year 1
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
        
        -- Update cost calculations based on driver value
        IF driver_value IS NOT NULL THEN
            UPDATE opex_lines 
            SET cost_year_1 = calculate_opex_cost(cpu, base_quantity, driver_value, driver_ratio, inflation, 1),
                cost_year_2 = calculate_opex_cost(cpu, base_quantity, driver_value, driver_ratio, inflation, 2),
                cost_year_3 = calculate_opex_cost(cpu, base_quantity, driver_value, driver_ratio, inflation, 3),
                cost_year_4 = calculate_opex_cost(cpu, base_quantity, driver_value, driver_ratio, inflation, 4),
                cost_year_5 = calculate_opex_cost(cpu, base_quantity, driver_value, driver_ratio, inflation, 5),
                cost_year_6 = calculate_opex_cost(cpu, base_quantity, driver_value, driver_ratio, inflation, 6),
                cost_year_7 = calculate_opex_cost(cpu, base_quantity, driver_value, driver_ratio, inflation, 7),
                cost_year_8 = calculate_opex_cost(cpu, base_quantity, driver_value, driver_ratio, inflation, 8),
                cost_year_9 = calculate_opex_cost(cpu, base_quantity, driver_value, driver_ratio, inflation, 9),
                cost_year_10 = calculate_opex_cost(cpu, base_quantity, driver_value, driver_ratio, inflation, 10),
                updated_at = NOW()
            WHERE id = opex_record.id;
        END IF;
    END LOOP;
END;
$function$;