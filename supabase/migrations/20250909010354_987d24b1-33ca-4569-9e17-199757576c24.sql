-- Phase 1: Price Stream Allocation Logic
-- Add price stream allocation tracking table
CREATE TABLE IF NOT EXISTS public.opex_price_allocations (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    opex_line_id UUID NOT NULL,
    volume_id UUID NOT NULL,
    allocation_percentage NUMERIC NOT NULL DEFAULT 0,
    allocation_method CHARACTER VARYING NOT NULL DEFAULT 'volume_based',
    allocated_cost_year_1 NUMERIC DEFAULT 0,
    allocated_cost_year_2 NUMERIC DEFAULT 0,
    allocated_cost_year_3 NUMERIC DEFAULT 0,
    allocated_cost_year_4 NUMERIC DEFAULT 0,
    allocated_cost_year_5 NUMERIC DEFAULT 0,
    allocated_cost_year_6 NUMERIC DEFAULT 0,
    allocated_cost_year_7 NUMERIC DEFAULT 0,
    allocated_cost_year_8 NUMERIC DEFAULT 0,
    allocated_cost_year_9 NUMERIC DEFAULT 0,
    allocated_cost_year_10 NUMERIC DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.opex_price_allocations ENABLE ROW LEVEL SECURITY;

-- Create policies for price allocations
CREATE POLICY "Users can manage price allocations for accessible models" 
ON public.opex_price_allocations 
FOR ALL 
USING (EXISTS (
    SELECT 1 FROM opex_lines ol
    JOIN models m ON ol.model_id = m.id
    JOIN projects p ON m.project_id = p.id
    WHERE ol.id = opex_price_allocations.opex_line_id 
    AND p.created_by = auth.uid()
));

-- Add site allocation tracking
CREATE TABLE IF NOT EXISTS public.opex_site_allocations (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    model_id UUID NOT NULL,
    opex_line_id UUID NOT NULL,
    allocation_percentage NUMERIC NOT NULL DEFAULT 0,
    base_cost NUMERIC NOT NULL DEFAULT 0,
    allocated_amount NUMERIC NOT NULL DEFAULT 0,
    allocation_type CHARACTER VARYING NOT NULL DEFAULT 'site_overhead',
    is_auto_generated BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.opex_site_allocations ENABLE ROW LEVEL SECURITY;

-- Create policies for site allocations
CREATE POLICY "Users can manage site allocations for accessible models" 
ON public.opex_site_allocations 
FOR ALL 
USING (EXISTS (
    SELECT 1 FROM models m
    JOIN projects p ON m.project_id = p.id
    WHERE m.id = opex_site_allocations.model_id 
    AND p.created_by = auth.uid()
));

-- Enhance opex_lines with additional allocation fields
ALTER TABLE public.opex_lines 
ADD COLUMN IF NOT EXISTS allocation_method CHARACTER VARYING DEFAULT 'manual',
ADD COLUMN IF NOT EXISTS is_site_allocation BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS cost_section CHARACTER VARYING DEFAULT 'direct',
ADD COLUMN IF NOT EXISTS override_reason TEXT,
ADD COLUMN IF NOT EXISTS is_cost_overridden BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS original_cost_year_1 NUMERIC,
ADD COLUMN IF NOT EXISTS original_cost_year_2 NUMERIC,
ADD COLUMN IF NOT EXISTS original_cost_year_3 NUMERIC,
ADD COLUMN IF NOT EXISTS original_cost_year_4 NUMERIC,
ADD COLUMN IF NOT EXISTS original_cost_year_5 NUMERIC,
ADD COLUMN IF NOT EXISTS original_cost_year_6 NUMERIC,
ADD COLUMN IF NOT EXISTS original_cost_year_7 NUMERIC,
ADD COLUMN IF NOT EXISTS original_cost_year_8 NUMERIC,
ADD COLUMN IF NOT EXISTS original_cost_year_9 NUMERIC,
ADD COLUMN IF NOT EXISTS original_cost_year_10 NUMERIC;

-- Function to calculate price stream allocation
CREATE OR REPLACE FUNCTION public.calculate_price_stream_allocation(
    p_opex_line_id UUID,
    p_allocation_method TEXT DEFAULT 'volume_based'
) RETURNS VOID 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path TO 'public' 
AS $$
DECLARE
    opex_record RECORD;
    volume_record RECORD;
    total_allocation_base NUMERIC := 0;
    allocation_percentage NUMERIC;
BEGIN
    -- Get the OPEX line
    SELECT * INTO opex_record FROM opex_lines WHERE id = p_opex_line_id;
    
    -- Clear existing allocations
    DELETE FROM opex_price_allocations WHERE opex_line_id = p_opex_line_id;
    
    -- Calculate total allocation base (volumes for volume_based method)
    IF p_allocation_method = 'volume_based' THEN
        SELECT SUM(year_1) INTO total_allocation_base 
        FROM volumes 
        WHERE model_id = opex_record.model_id 
        AND is_price_item = true;
    ELSIF p_allocation_method = 'revenue_based' THEN
        SELECT SUM(year_1 * price_1) INTO total_allocation_base 
        FROM volumes 
        WHERE model_id = opex_record.model_id 
        AND is_price_item = true;
    END IF;
    
    -- Allocate to each price stream
    FOR volume_record IN 
        SELECT * FROM volumes 
        WHERE model_id = opex_record.model_id 
        AND is_price_item = true
    LOOP
        -- Calculate allocation percentage
        IF p_allocation_method = 'volume_based' THEN
            allocation_percentage = CASE 
                WHEN total_allocation_base > 0 THEN volume_record.year_1 / total_allocation_base 
                ELSE 0 
            END;
        ELSIF p_allocation_method = 'revenue_based' THEN
            allocation_percentage = CASE 
                WHEN total_allocation_base > 0 THEN (volume_record.year_1 * volume_record.price_1) / total_allocation_base 
                ELSE 0 
            END;
        ELSE
            allocation_percentage = 0;
        END IF;
        
        -- Insert allocation record
        INSERT INTO opex_price_allocations (
            opex_line_id, volume_id, allocation_percentage, allocation_method,
            allocated_cost_year_1, allocated_cost_year_2, allocated_cost_year_3,
            allocated_cost_year_4, allocated_cost_year_5, allocated_cost_year_6,
            allocated_cost_year_7, allocated_cost_year_8, allocated_cost_year_9,
            allocated_cost_year_10
        ) VALUES (
            p_opex_line_id, volume_record.id, allocation_percentage, p_allocation_method,
            opex_record.cost_year_1 * allocation_percentage,
            opex_record.cost_year_2 * allocation_percentage,
            opex_record.cost_year_3 * allocation_percentage,
            opex_record.cost_year_4 * allocation_percentage,
            opex_record.cost_year_5 * allocation_percentage,
            opex_record.cost_year_6 * allocation_percentage,
            opex_record.cost_year_7 * allocation_percentage,
            opex_record.cost_year_8 * allocation_percentage,
            opex_record.cost_year_9 * allocation_percentage,
            opex_record.cost_year_10 * allocation_percentage
        );
    END LOOP;
END;
$$;

-- Function to auto-generate site allocation costs
CREATE OR REPLACE FUNCTION public.update_site_allocation_costs(p_model_id UUID)
RETURNS VOID 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path TO 'public' 
AS $$
DECLARE
    site_allocation_rate NUMERIC := 0;
    total_operational_costs NUMERIC := 0;
    site_allocation_amount NUMERIC := 0;
    existing_site_line_id UUID;
BEGIN
    -- Get site allocation rate from finance parameters
    SELECT COALESCE((data->>'site_allocation')::NUMERIC, 0) / 100 
    INTO site_allocation_rate
    FROM model_parameters 
    WHERE model_id = p_model_id 
    AND parameter_type = 'finance';
    
    -- Calculate total operational costs (excluding existing site allocation)
    SELECT SUM(cost_year_1) 
    INTO total_operational_costs
    FROM opex_lines 
    WHERE model_id = p_model_id 
    AND is_site_allocation = false;
    
    -- Calculate site allocation amount
    site_allocation_amount = total_operational_costs * site_allocation_rate;
    
    -- Check if site allocation line already exists
    SELECT id INTO existing_site_line_id
    FROM opex_lines 
    WHERE model_id = p_model_id 
    AND is_site_allocation = true
    LIMIT 1;
    
    -- Update or create site allocation line
    IF existing_site_line_id IS NOT NULL THEN
        UPDATE opex_lines 
        SET cost_year_1 = site_allocation_amount,
            cost_year_2 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 1),
            cost_year_3 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 2),
            cost_year_4 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 3),
            cost_year_5 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 4),
            cost_year_6 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 5),
            cost_year_7 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 6),
            cost_year_8 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 7),
            cost_year_9 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 8),
            cost_year_10 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 9),
            updated_at = NOW()
        WHERE id = existing_site_line_id;
    ELSIF site_allocation_amount > 0 THEN
        INSERT INTO opex_lines (
            model_id, category, description, cost_section,
            is_site_allocation, protected, allocation_method,
            cost_year_1, cost_year_2, cost_year_3, cost_year_4, cost_year_5,
            cost_year_6, cost_year_7, cost_year_8, cost_year_9, cost_year_10,
            cpu, base_quantity, inflation, pf_assignment
        ) VALUES (
            p_model_id, 'Site Allocation', 'Automated site allocation based on operational costs',
            'overhead', true, true, 'site_percentage',
            site_allocation_amount,
            site_allocation_amount * POWER(1 + 0.03, 1),
            site_allocation_amount * POWER(1 + 0.03, 2),
            site_allocation_amount * POWER(1 + 0.03, 3),
            site_allocation_amount * POWER(1 + 0.03, 4),
            site_allocation_amount * POWER(1 + 0.03, 5),
            site_allocation_amount * POWER(1 + 0.03, 6),
            site_allocation_amount * POWER(1 + 0.03, 7),
            site_allocation_amount * POWER(1 + 0.03, 8),
            site_allocation_amount * POWER(1 + 0.03, 9),
            site_allocation_rate, total_operational_costs, 0.03, 1
        );
    END IF;
END;
$$;

-- Create trigger to auto-update site allocation when OPEX changes
CREATE OR REPLACE FUNCTION public.trigger_update_site_allocation()
RETURNS TRIGGER 
LANGUAGE plpgsql 
AS $$
BEGIN
    -- Only trigger for non-site-allocation lines
    IF COALESCE(NEW.is_site_allocation, false) = false THEN
        PERFORM update_site_allocation_costs(NEW.model_id);
    END IF;
    RETURN NEW;
END;
$$;

-- Create trigger
DROP TRIGGER IF EXISTS opex_site_allocation_trigger ON opex_lines;
CREATE TRIGGER opex_site_allocation_trigger
    AFTER INSERT OR UPDATE OF cost_year_1, cost_year_2, cost_year_3, cost_year_4, cost_year_5,
           cost_year_6, cost_year_7, cost_year_8, cost_year_9, cost_year_10
    ON opex_lines
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_site_allocation();

-- Add updated_at trigger for new tables
CREATE TRIGGER update_opex_price_allocations_updated_at
    BEFORE UPDATE ON opex_price_allocations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_opex_site_allocations_updated_at
    BEFORE UPDATE ON opex_site_allocations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();