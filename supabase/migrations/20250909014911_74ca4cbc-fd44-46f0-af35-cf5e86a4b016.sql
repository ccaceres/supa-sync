-- Enhance IMPEX lines table with comprehensive implementation expense fields
ALTER TABLE public.impex_lines 
ADD COLUMN IF NOT EXISTS item_name character varying NOT NULL DEFAULT '',
ADD COLUMN IF NOT EXISTS quantity numeric DEFAULT 1,
ADD COLUMN IF NOT EXISTS unit_cost numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS currency character varying DEFAULT 'USD',
ADD COLUMN IF NOT EXISTS unit_of_measure character varying DEFAULT 'Units',
ADD COLUMN IF NOT EXISTS charging_method character varying DEFAULT 'upfront',
ADD COLUMN IF NOT EXISTS depreciation_years integer,
ADD COLUMN IF NOT EXISTS cost_imposition integer,
ADD COLUMN IF NOT EXISTS charging_treatment integer,
ADD COLUMN IF NOT EXISTS margin_markup numeric,
ADD COLUMN IF NOT EXISTS total_upfront numeric,
ADD COLUMN IF NOT EXISTS pf_assignment integer DEFAULT 1,
ADD COLUMN IF NOT EXISTS driver_id uuid,
ADD COLUMN IF NOT EXISTS driver_ratio numeric DEFAULT 1,
ADD COLUMN IF NOT EXISTS notes text,
ADD COLUMN IF NOT EXISTS row_order integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_cost numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS is_cost_overridden boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS override_reason text;

-- Add check constraints for charging method
ALTER TABLE public.impex_lines 
ADD CONSTRAINT check_charging_method 
CHECK (charging_method IN ('upfront', 'amortise'));

-- Add check constraints for charging treatment (0 = margin, 1 = markup)
ALTER TABLE public.impex_lines 
ADD CONSTRAINT check_charging_treatment 
CHECK (charging_treatment IN (0, 1) OR charging_treatment IS NULL);

-- Create function to calculate total IMPEX cost
CREATE OR REPLACE FUNCTION public.calculate_impex_total_cost()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate base total cost
    NEW.total_cost = COALESCE(NEW.quantity, 0) * COALESCE(NEW.unit_cost, 0);
    
    -- Calculate total upfront for upfront charging method
    IF NEW.charging_method = 'upfront' AND NEW.margin_markup IS NOT NULL AND NEW.charging_treatment IS NOT NULL THEN
        IF NEW.charging_treatment = 0 THEN
            -- Margin calculation: Cost / (1 - margin%)
            NEW.total_upfront = NEW.total_cost / (1 - (NEW.margin_markup / 100));
        ELSE
            -- Markup calculation: Cost * (1 + markup%)
            NEW.total_upfront = NEW.total_cost * (1 + (NEW.margin_markup / 100));
        END IF;
    ELSE
        NEW.total_upfront = NEW.total_cost;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic cost calculation
CREATE TRIGGER trigger_calculate_impex_total_cost
    BEFORE INSERT OR UPDATE ON public.impex_lines
    FOR EACH ROW
    EXECUTE FUNCTION public.calculate_impex_total_cost();

-- Create function to update IMPEX row order
CREATE OR REPLACE FUNCTION public.update_impex_row_order()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.row_order IS NULL OR NEW.row_order = 0 THEN
        SELECT COALESCE(MAX(row_order), 0) + 1 
        INTO NEW.row_order 
        FROM impex_lines 
        WHERE model_id = NEW.model_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for row order management
CREATE TRIGGER trigger_update_impex_row_order
    BEFORE INSERT ON public.impex_lines
    FOR EACH ROW
    EXECUTE FUNCTION public.update_impex_row_order();

-- Create function to sync IMPEX costs when drivers change
CREATE OR REPLACE FUNCTION public.update_impex_from_driver(p_model_id uuid, p_driver_id uuid, p_driver_type text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    impex_record RECORD;
    driver_value NUMERIC;
BEGIN
    -- Update all IMPEX items linked to this driver
    FOR impex_record IN 
        SELECT * FROM impex_lines 
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
        
        -- Update quantity based on driver value and ratio
        IF driver_value IS NOT NULL THEN
            UPDATE impex_lines 
            SET quantity = driver_value * COALESCE(driver_ratio, 1),
                updated_at = NOW()
            WHERE id = impex_record.id;
        END IF;
    END LOOP;
END;
$$;