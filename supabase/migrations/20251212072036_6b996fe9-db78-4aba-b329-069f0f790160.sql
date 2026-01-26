-- Fix Year 14 copy-paste bug in get_allocated_costs_for_price_line
-- Line 248 incorrectly uses yearly_total_cost_15 instead of yearly_total_cost_14

CREATE OR REPLACE FUNCTION public.get_allocated_costs_for_price_line(p_price_line_id uuid, p_model_id uuid)
RETURNS numeric[]
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  total_costs NUMERIC[] := ARRAY_FILL(0::NUMERIC, ARRAY[20]);
  allocation_record RECORD;
  yearly_costs NUMERIC[];
  allocated_percentage NUMERIC;
  year_idx INTEGER;
BEGIN
  -- Get costs from cost_price_allocations (LABEX, OPEX, CAPEX, IMPEX)
  FOR allocation_record IN 
    SELECT 
      cpa.cost_type,
      cpa.cost_item_id,
      cpa.allocation_percentage
    FROM cost_price_allocations cpa
    WHERE cpa.price_line_id = p_price_line_id
    AND cpa.model_id = p_model_id
  LOOP
    allocated_percentage := COALESCE(allocation_record.allocation_percentage, 100) / 100.0;
    
    IF allocation_record.cost_type = 'labex' THEN
      -- Get LABEX (dl_roles) costs
      SELECT ARRAY[
        COALESCE(yearly_total_cost_1, 0), COALESCE(yearly_total_cost_2, 0), COALESCE(yearly_total_cost_3, 0),
        COALESCE(yearly_total_cost_4, 0), COALESCE(yearly_total_cost_5, 0), COALESCE(yearly_total_cost_6, 0),
        COALESCE(yearly_total_cost_7, 0), COALESCE(yearly_total_cost_8, 0), COALESCE(yearly_total_cost_9, 0),
        COALESCE(yearly_total_cost_10, 0), COALESCE(yearly_total_cost_11, 0), COALESCE(yearly_total_cost_12, 0),
        COALESCE(yearly_total_cost_13, 0), COALESCE(yearly_total_cost_14, 0), COALESCE(yearly_total_cost_15, 0),
        COALESCE(yearly_total_cost_16, 0), COALESCE(yearly_total_cost_17, 0), COALESCE(yearly_total_cost_18, 0),
        COALESCE(yearly_total_cost_19, 0), COALESCE(yearly_total_cost_20, 0)
      ] INTO yearly_costs
      FROM dl_roles WHERE id = allocation_record.cost_item_id;
      
    ELSIF allocation_record.cost_type = 'opex' THEN
      -- Get OPEX costs
      SELECT ARRAY[
        COALESCE(cost_year_1, 0), COALESCE(cost_year_2, 0), COALESCE(cost_year_3, 0),
        COALESCE(cost_year_4, 0), COALESCE(cost_year_5, 0), COALESCE(cost_year_6, 0),
        COALESCE(cost_year_7, 0), COALESCE(cost_year_8, 0), COALESCE(cost_year_9, 0),
        COALESCE(cost_year_10, 0), COALESCE(cost_year_11, 0), COALESCE(cost_year_12, 0),
        COALESCE(cost_year_13, 0), COALESCE(cost_year_14, 0), COALESCE(cost_year_15, 0),
        COALESCE(cost_year_16, 0), COALESCE(cost_year_17, 0), COALESCE(cost_year_18, 0),
        COALESCE(cost_year_19, 0), COALESCE(cost_year_20, 0)
      ] INTO yearly_costs
      FROM opex_lines WHERE id = allocation_record.cost_item_id;
      
    ELSIF allocation_record.cost_type = 'capex' THEN
      -- Get CAPEX costs
      SELECT ARRAY[
        COALESCE(cost_year_1, 0), COALESCE(cost_year_2, 0), COALESCE(cost_year_3, 0),
        COALESCE(cost_year_4, 0), COALESCE(cost_year_5, 0), COALESCE(cost_year_6, 0),
        COALESCE(cost_year_7, 0), COALESCE(cost_year_8, 0), COALESCE(cost_year_9, 0),
        COALESCE(cost_year_10, 0), COALESCE(cost_year_11, 0), COALESCE(cost_year_12, 0),
        COALESCE(cost_year_13, 0), COALESCE(cost_year_14, 0), COALESCE(cost_year_15, 0),
        COALESCE(cost_year_16, 0), COALESCE(cost_year_17, 0), COALESCE(cost_year_18, 0),
        COALESCE(cost_year_19, 0), COALESCE(cost_year_20, 0)
      ] INTO yearly_costs
      FROM capex_lines WHERE id = allocation_record.cost_item_id;
      
    ELSIF allocation_record.cost_type = 'impex' THEN
      -- Get IMPEX costs
      SELECT ARRAY[
        COALESCE(cost_year_1, 0), COALESCE(cost_year_2, 0), COALESCE(cost_year_3, 0),
        COALESCE(cost_year_4, 0), COALESCE(cost_year_5, 0), COALESCE(cost_year_6, 0),
        COALESCE(cost_year_7, 0), COALESCE(cost_year_8, 0), COALESCE(cost_year_9, 0),
        COALESCE(cost_year_10, 0), COALESCE(cost_year_11, 0), COALESCE(cost_year_12, 0),
        COALESCE(cost_year_13, 0), COALESCE(cost_year_14, 0), COALESCE(cost_year_15, 0),
        COALESCE(cost_year_16, 0), COALESCE(cost_year_17, 0), COALESCE(cost_year_18, 0),
        COALESCE(cost_year_19, 0), COALESCE(cost_year_20, 0)
      ] INTO yearly_costs
      FROM impex_lines WHERE id = allocation_record.cost_item_id;
    END IF;
    
    -- Add allocated costs to totals
    IF yearly_costs IS NOT NULL THEN
      FOR year_idx IN 1..20 LOOP
        total_costs[year_idx] := total_costs[year_idx] + (yearly_costs[year_idx] * allocated_percentage);
      END LOOP;
    END IF;
  END LOOP;
  
  -- Add indirect labor costs (labex_indirect_labor table)
  FOR allocation_record IN 
    SELECT 
      COALESCE(yearly_total_cost_1, 0) as cost_1, COALESCE(yearly_total_cost_2, 0) as cost_2,
      COALESCE(yearly_total_cost_3, 0) as cost_3, COALESCE(yearly_total_cost_4, 0) as cost_4,
      COALESCE(yearly_total_cost_5, 0) as cost_5, COALESCE(yearly_total_cost_6, 0) as cost_6,
      COALESCE(yearly_total_cost_7, 0) as cost_7, COALESCE(yearly_total_cost_8, 0) as cost_8,
      COALESCE(yearly_total_cost_9, 0) as cost_9, COALESCE(yearly_total_cost_10, 0) as cost_10,
      COALESCE(yearly_total_cost_11, 0) as cost_11, COALESCE(yearly_total_cost_12, 0) as cost_12,
      COALESCE(yearly_total_cost_13, 0) as cost_13, COALESCE(yearly_total_cost_14, 0) as cost_14,
      COALESCE(yearly_total_cost_15, 0) as cost_15, COALESCE(yearly_total_cost_16, 0) as cost_16,
      COALESCE(yearly_total_cost_17, 0) as cost_17, COALESCE(yearly_total_cost_18, 0) as cost_18,
      COALESCE(yearly_total_cost_19, 0) as cost_19, COALESCE(yearly_total_cost_20, 0) as cost_20,
      COALESCE(price_line_imposition, 100) as imposition
    FROM labex_indirect_labor 
    WHERE price_line_id = p_price_line_id
    AND model_id = p_model_id
  LOOP
    allocated_percentage := allocation_record.imposition / 100.0;
    total_costs[1] := total_costs[1] + (allocation_record.cost_1 * allocated_percentage);
    total_costs[2] := total_costs[2] + (allocation_record.cost_2 * allocated_percentage);
    total_costs[3] := total_costs[3] + (allocation_record.cost_3 * allocated_percentage);
    total_costs[4] := total_costs[4] + (allocation_record.cost_4 * allocated_percentage);
    total_costs[5] := total_costs[5] + (allocation_record.cost_5 * allocated_percentage);
    total_costs[6] := total_costs[6] + (allocation_record.cost_6 * allocated_percentage);
    total_costs[7] := total_costs[7] + (allocation_record.cost_7 * allocated_percentage);
    total_costs[8] := total_costs[8] + (allocation_record.cost_8 * allocated_percentage);
    total_costs[9] := total_costs[9] + (allocation_record.cost_9 * allocated_percentage);
    total_costs[10] := total_costs[10] + (allocation_record.cost_10 * allocated_percentage);
    total_costs[11] := total_costs[11] + (allocation_record.cost_11 * allocated_percentage);
    total_costs[12] := total_costs[12] + (allocation_record.cost_12 * allocated_percentage);
    total_costs[13] := total_costs[13] + (allocation_record.cost_13 * allocated_percentage);
    total_costs[14] := total_costs[14] + (allocation_record.cost_14 * allocated_percentage);
    total_costs[15] := total_costs[15] + (allocation_record.cost_15 * allocated_percentage);
    total_costs[16] := total_costs[16] + (allocation_record.cost_16 * allocated_percentage);
    total_costs[17] := total_costs[17] + (allocation_record.cost_17 * allocated_percentage);
    total_costs[18] := total_costs[18] + (allocation_record.cost_18 * allocated_percentage);
    total_costs[19] := total_costs[19] + (allocation_record.cost_19 * allocated_percentage);
    total_costs[20] := total_costs[20] + (allocation_record.cost_20 * allocated_percentage);
  END LOOP;
  
  -- Add direct labor costs linked via price_line_id (not already in allocations)
  FOR allocation_record IN 
    SELECT 
      COALESCE(yearly_total_cost_1, 0) as cost_1, COALESCE(yearly_total_cost_2, 0) as cost_2,
      COALESCE(yearly_total_cost_3, 0) as cost_3, COALESCE(yearly_total_cost_4, 0) as cost_4,
      COALESCE(yearly_total_cost_5, 0) as cost_5, COALESCE(yearly_total_cost_6, 0) as cost_6,
      COALESCE(yearly_total_cost_7, 0) as cost_7, COALESCE(yearly_total_cost_8, 0) as cost_8,
      COALESCE(yearly_total_cost_9, 0) as cost_9, COALESCE(yearly_total_cost_10, 0) as cost_10,
      COALESCE(yearly_total_cost_11, 0) as cost_11, COALESCE(yearly_total_cost_12, 0) as cost_12,
      COALESCE(yearly_total_cost_13, 0) as cost_13, COALESCE(yearly_total_cost_14, 0) as cost_14,
      COALESCE(yearly_total_cost_15, 0) as cost_15, COALESCE(yearly_total_cost_16, 0) as cost_16,
      COALESCE(yearly_total_cost_17, 0) as cost_17, COALESCE(yearly_total_cost_18, 0) as cost_18,
      COALESCE(yearly_total_cost_19, 0) as cost_19, COALESCE(yearly_total_cost_20, 0) as cost_20,
      COALESCE(price_line_imposition, 100) as imposition
    FROM dl_roles 
    WHERE price_line_id = p_price_line_id
    AND model_id = p_model_id
    AND id NOT IN (
      SELECT cost_item_id FROM cost_price_allocations 
      WHERE price_line_id = p_price_line_id AND cost_type = 'labex'
    )
  LOOP
    allocated_percentage := allocation_record.imposition / 100.0;
    total_costs[1] := total_costs[1] + (allocation_record.cost_1 * allocated_percentage);
    total_costs[2] := total_costs[2] + (allocation_record.cost_2 * allocated_percentage);
    total_costs[3] := total_costs[3] + (allocation_record.cost_3 * allocated_percentage);
    total_costs[4] := total_costs[4] + (allocation_record.cost_4 * allocated_percentage);
    total_costs[5] := total_costs[5] + (allocation_record.cost_5 * allocated_percentage);
    total_costs[6] := total_costs[6] + (allocation_record.cost_6 * allocated_percentage);
    total_costs[7] := total_costs[7] + (allocation_record.cost_7 * allocated_percentage);
    total_costs[8] := total_costs[8] + (allocation_record.cost_8 * allocated_percentage);
    total_costs[9] := total_costs[9] + (allocation_record.cost_9 * allocated_percentage);
    total_costs[10] := total_costs[10] + (allocation_record.cost_10 * allocated_percentage);
    total_costs[11] := total_costs[11] + (allocation_record.cost_11 * allocated_percentage);
    total_costs[12] := total_costs[12] + (allocation_record.cost_12 * allocated_percentage);
    total_costs[13] := total_costs[13] + (allocation_record.cost_13 * allocated_percentage);
    total_costs[14] := total_costs[14] + (allocation_record.cost_14 * allocated_percentage);
    total_costs[15] := total_costs[15] + (allocation_record.cost_15 * allocated_percentage);
    total_costs[16] := total_costs[16] + (allocation_record.cost_16 * allocated_percentage);
    total_costs[17] := total_costs[17] + (allocation_record.cost_17 * allocated_percentage);
    total_costs[18] := total_costs[18] + (allocation_record.cost_18 * allocated_percentage);
    total_costs[19] := total_costs[19] + (allocation_record.cost_19 * allocated_percentage);
    total_costs[20] := total_costs[20] + (allocation_record.cost_20 * allocated_percentage);
  END LOOP;
  
  RETURN total_costs;
END;
$function$;