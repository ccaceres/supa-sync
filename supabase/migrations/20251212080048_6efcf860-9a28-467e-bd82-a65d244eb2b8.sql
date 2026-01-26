-- Drop the broken TABLE-returning function first
DROP FUNCTION IF EXISTS public.get_allocated_costs_for_price_line(uuid);

-- Restore the correct numeric[]-returning function with fixed direct labor allocation
CREATE OR REPLACE FUNCTION public.get_allocated_costs_for_price_line(p_price_line_id uuid)
RETURNS numeric[]
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  result numeric[] := ARRAY[]::numeric[];
  year_costs numeric[];
  i integer;
  total_costs numeric[] := ARRAY[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]::numeric[];
BEGIN
  -- Get costs from cost_price_allocations table (dl_roles via allocation table)
  FOR year_costs IN
    SELECT ARRAY[
      COALESCE(SUM(dr.yearly_total_cost_1 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_2 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_3 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_4 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_5 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_6 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_7 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_8 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_9 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_10 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_11 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_12 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_13 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_14 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_15 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_16 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_17 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_18 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_19 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(dr.yearly_total_cost_20 * cpa.allocation_percentage / 100), 0)
    ]
    FROM cost_price_allocations cpa
    JOIN dl_roles dr ON dr.id = cpa.cost_item_id
    WHERE cpa.price_line_id = p_price_line_id
    AND cpa.cost_type = 'labex_direct'
  LOOP
    FOR i IN 1..20 LOOP
      total_costs[i] := total_costs[i] + COALESCE(year_costs[i], 0);
    END LOOP;
  END LOOP;

  -- Get costs from dl_roles directly linked via price_line_id (100% allocation - FIXED)
  FOR year_costs IN
    SELECT ARRAY[
      COALESCE(SUM(yearly_total_cost_1 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_2 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_3 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_4 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_5 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_6 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_7 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_8 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_9 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_10 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_11 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_12 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_13 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_14 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_15 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_16 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_17 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_18 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_19 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_20 * 100 / 100), 0)
    ]
    FROM dl_roles
    WHERE price_line_id = p_price_line_id
  LOOP
    FOR i IN 1..20 LOOP
      total_costs[i] := total_costs[i] + COALESCE(year_costs[i], 0);
    END LOOP;
  END LOOP;

  -- Get costs from labex_indirect_labor via allocation table
  FOR year_costs IN
    SELECT ARRAY[
      COALESCE(SUM(il.yearly_total_cost_1 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_2 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_3 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_4 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_5 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_6 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_7 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_8 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_9 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_10 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_11 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_12 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_13 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_14 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_15 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_16 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_17 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_18 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_19 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.yearly_total_cost_20 * cpa.allocation_percentage / 100), 0)
    ]
    FROM cost_price_allocations cpa
    JOIN labex_indirect_labor il ON il.id = cpa.cost_item_id
    WHERE cpa.price_line_id = p_price_line_id
    AND cpa.cost_type = 'labex_indirect'
  LOOP
    FOR i IN 1..20 LOOP
      total_costs[i] := total_costs[i] + COALESCE(year_costs[i], 0);
    END LOOP;
  END LOOP;

  -- Get costs from labex_indirect_labor directly linked via price_line_id (100% allocation)
  FOR year_costs IN
    SELECT ARRAY[
      COALESCE(SUM(yearly_total_cost_1 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_2 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_3 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_4 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_5 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_6 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_7 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_8 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_9 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_10 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_11 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_12 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_13 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_14 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_15 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_16 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_17 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_18 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_19 * 100 / 100), 0),
      COALESCE(SUM(yearly_total_cost_20 * 100 / 100), 0)
    ]
    FROM labex_indirect_labor
    WHERE price_line_id = p_price_line_id
  LOOP
    FOR i IN 1..20 LOOP
      total_costs[i] := total_costs[i] + COALESCE(year_costs[i], 0);
    END LOOP;
  END LOOP;

  -- Get costs from opex_lines via allocation table
  FOR year_costs IN
    SELECT ARRAY[
      COALESCE(SUM(ol.cost_year_1 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_2 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_3 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_4 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_5 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_6 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_7 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_8 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_9 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_10 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_11 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_12 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_13 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_14 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_15 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_16 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_17 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_18 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_19 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(ol.cost_year_20 * cpa.allocation_percentage / 100), 0)
    ]
    FROM cost_price_allocations cpa
    JOIN opex_lines ol ON ol.id = cpa.cost_item_id
    WHERE cpa.price_line_id = p_price_line_id
    AND cpa.cost_type = 'opex'
  LOOP
    FOR i IN 1..20 LOOP
      total_costs[i] := total_costs[i] + COALESCE(year_costs[i], 0);
    END LOOP;
  END LOOP;

  -- Get costs from capex_lines via allocation table
  FOR year_costs IN
    SELECT ARRAY[
      COALESCE(SUM(cl.cost_year_1 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_2 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_3 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_4 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_5 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_6 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_7 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_8 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_9 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_10 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_11 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_12 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_13 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_14 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_15 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_16 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_17 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_18 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_19 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(cl.cost_year_20 * cpa.allocation_percentage / 100), 0)
    ]
    FROM cost_price_allocations cpa
    JOIN capex_lines cl ON cl.id = cpa.cost_item_id
    WHERE cpa.price_line_id = p_price_line_id
    AND cpa.cost_type = 'capex'
  LOOP
    FOR i IN 1..20 LOOP
      total_costs[i] := total_costs[i] + COALESCE(year_costs[i], 0);
    END LOOP;
  END LOOP;

  -- Get costs from impex_lines via allocation table
  FOR year_costs IN
    SELECT ARRAY[
      COALESCE(SUM(il.cost_year_1 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_2 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_3 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_4 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_5 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_6 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_7 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_8 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_9 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_10 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_11 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_12 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_13 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_14 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_15 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_16 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_17 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_18 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_19 * cpa.allocation_percentage / 100), 0),
      COALESCE(SUM(il.cost_year_20 * cpa.allocation_percentage / 100), 0)
    ]
    FROM cost_price_allocations cpa
    JOIN impex_lines il ON il.id = cpa.cost_item_id
    WHERE cpa.price_line_id = p_price_line_id
    AND cpa.cost_type = 'impex'
  LOOP
    FOR i IN 1..20 LOOP
      total_costs[i] := total_costs[i] + COALESCE(year_costs[i], 0);
    END LOOP;
  END LOOP;

  RETURN total_costs;
END;
$function$;