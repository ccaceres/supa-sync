-- Fix site allocation rate calculation - remove incorrect /100 division
-- The site_allocation value is already stored as a decimal (0.05 for 5%)
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
    -- FIXED: Removed / 100 since value is already stored as decimal (0.05 for 5%)
    SELECT COALESCE((data->>'site_allocation')::NUMERIC, 0)
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
            cost_year_11 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 10),
            cost_year_12 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 11),
            cost_year_13 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 12),
            cost_year_14 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 13),
            cost_year_15 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 14),
            cost_year_16 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 15),
            cost_year_17 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 16),
            cost_year_18 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 17),
            cost_year_19 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 18),
            cost_year_20 = site_allocation_amount * POWER(1 + COALESCE(inflation, 0.03), 19),
            updated_at = NOW()
        WHERE id = existing_site_line_id;
    ELSIF site_allocation_amount > 0 THEN
        INSERT INTO opex_lines (
            model_id, category, description, cost_section,
            is_site_allocation, protected, allocation_method,
            cost_year_1, cost_year_2, cost_year_3, cost_year_4, cost_year_5,
            cost_year_6, cost_year_7, cost_year_8, cost_year_9, cost_year_10,
            cost_year_11, cost_year_12, cost_year_13, cost_year_14, cost_year_15,
            cost_year_16, cost_year_17, cost_year_18, cost_year_19, cost_year_20,
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
            site_allocation_amount * POWER(1 + 0.03, 10),
            site_allocation_amount * POWER(1 + 0.03, 11),
            site_allocation_amount * POWER(1 + 0.03, 12),
            site_allocation_amount * POWER(1 + 0.03, 13),
            site_allocation_amount * POWER(1 + 0.03, 14),
            site_allocation_amount * POWER(1 + 0.03, 15),
            site_allocation_amount * POWER(1 + 0.03, 16),
            site_allocation_amount * POWER(1 + 0.03, 17),
            site_allocation_amount * POWER(1 + 0.03, 18),
            site_allocation_amount * POWER(1 + 0.03, 19),
            site_allocation_rate, total_operational_costs, 0.03, 1
        );
    END IF;
END;
$$;