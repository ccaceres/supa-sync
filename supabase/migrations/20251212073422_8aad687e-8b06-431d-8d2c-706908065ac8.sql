-- Fix: Direct labor via price_line_id should use 100% allocation (matching frontend behavior)
-- Need to drop and recreate due to return type change

DROP FUNCTION IF EXISTS public.get_allocated_costs_for_price_line(uuid, uuid);

CREATE FUNCTION public.get_allocated_costs_for_price_line(p_price_line_id uuid, p_model_id uuid)
RETURNS TABLE(
  cost_type text,
  cost_item_id uuid,
  cost_item_name text,
  allocation_percentage numeric,
  yearly_costs numeric[]
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  
  -- LABEX Direct costs from cost_price_allocations table
  SELECT 
    'labex_direct'::text as cost_type,
    dl.id as cost_item_id,
    dl.dl_role_name as cost_item_name,
    cpa.allocation_percentage,
    ARRAY[
      COALESCE(dl.yearly_total_cost_1, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_2, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_3, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_4, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_5, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_6, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_7, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_8, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_9, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_10, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_11, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_12, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_13, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_14, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_15, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_16, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_17, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_18, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_19, 0) * cpa.allocation_percentage / 100,
      COALESCE(dl.yearly_total_cost_20, 0) * cpa.allocation_percentage / 100
    ]::numeric[] as yearly_costs
  FROM cost_price_allocations cpa
  JOIN dl_roles dl ON dl.id = cpa.cost_item_id
  WHERE cpa.price_line_id = p_price_line_id
    AND cpa.model_id = p_model_id
    AND cpa.cost_type = 'labex_direct'
  
  UNION ALL
  
  -- LABEX Direct costs from direct price_line_id relationship (100% allocation - FIXED)
  SELECT 
    'labex_direct'::text as cost_type,
    dl.id as cost_item_id,
    dl.dl_role_name as cost_item_name,
    100::numeric as allocation_percentage,
    ARRAY[
      COALESCE(dl.yearly_total_cost_1, 0),
      COALESCE(dl.yearly_total_cost_2, 0),
      COALESCE(dl.yearly_total_cost_3, 0),
      COALESCE(dl.yearly_total_cost_4, 0),
      COALESCE(dl.yearly_total_cost_5, 0),
      COALESCE(dl.yearly_total_cost_6, 0),
      COALESCE(dl.yearly_total_cost_7, 0),
      COALESCE(dl.yearly_total_cost_8, 0),
      COALESCE(dl.yearly_total_cost_9, 0),
      COALESCE(dl.yearly_total_cost_10, 0),
      COALESCE(dl.yearly_total_cost_11, 0),
      COALESCE(dl.yearly_total_cost_12, 0),
      COALESCE(dl.yearly_total_cost_13, 0),
      COALESCE(dl.yearly_total_cost_14, 0),
      COALESCE(dl.yearly_total_cost_15, 0),
      COALESCE(dl.yearly_total_cost_16, 0),
      COALESCE(dl.yearly_total_cost_17, 0),
      COALESCE(dl.yearly_total_cost_18, 0),
      COALESCE(dl.yearly_total_cost_19, 0),
      COALESCE(dl.yearly_total_cost_20, 0)
    ]::numeric[] as yearly_costs
  FROM dl_roles dl
  WHERE dl.price_line_id = p_price_line_id
    AND dl.model_id = p_model_id
    AND NOT EXISTS (
      SELECT 1 FROM cost_price_allocations cpa 
      WHERE cpa.cost_item_id = dl.id 
        AND cpa.price_line_id = p_price_line_id
        AND cpa.cost_type = 'labex_direct'
    )
  
  UNION ALL
  
  -- LABEX Indirect costs
  SELECT 
    'labex_indirect'::text as cost_type,
    ep.id as cost_item_id,
    ep.title as cost_item_name,
    cpa.allocation_percentage,
    ARRAY[
      COALESCE(ep.yearly_total_cost_1, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_2, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_3, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_4, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_5, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_6, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_7, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_8, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_9, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_10, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_11, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_12, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_13, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_14, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_15, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_16, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_17, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_18, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_19, 0) * cpa.allocation_percentage / 100,
      COALESCE(ep.yearly_total_cost_20, 0) * cpa.allocation_percentage / 100
    ]::numeric[] as yearly_costs
  FROM cost_price_allocations cpa
  JOIN exempt_positions ep ON ep.id = cpa.cost_item_id
  WHERE cpa.price_line_id = p_price_line_id
    AND cpa.model_id = p_model_id
    AND cpa.cost_type = 'labex_indirect'
  
  UNION ALL
  
  -- OPEX costs
  SELECT 
    'opex'::text as cost_type,
    ol.id as cost_item_id,
    ol.item_name as cost_item_name,
    cpa.allocation_percentage,
    ARRAY[
      COALESCE(ol.cost_year_1, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_2, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_3, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_4, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_5, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_6, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_7, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_8, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_9, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_10, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_11, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_12, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_13, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_14, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_15, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_16, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_17, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_18, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_19, 0) * cpa.allocation_percentage / 100,
      COALESCE(ol.cost_year_20, 0) * cpa.allocation_percentage / 100
    ]::numeric[] as yearly_costs
  FROM cost_price_allocations cpa
  JOIN opex_lines ol ON ol.id = cpa.cost_item_id
  WHERE cpa.price_line_id = p_price_line_id
    AND cpa.model_id = p_model_id
    AND cpa.cost_type = 'opex'
  
  UNION ALL
  
  -- CAPEX costs
  SELECT 
    'capex'::text as cost_type,
    cl.id as cost_item_id,
    cl.item_name as cost_item_name,
    cpa.allocation_percentage,
    ARRAY[
      COALESCE(cl.cost_year_1, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_2, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_3, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_4, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_5, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_6, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_7, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_8, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_9, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_10, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_11, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_12, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_13, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_14, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_15, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_16, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_17, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_18, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_19, 0) * cpa.allocation_percentage / 100,
      COALESCE(cl.cost_year_20, 0) * cpa.allocation_percentage / 100
    ]::numeric[] as yearly_costs
  FROM cost_price_allocations cpa
  JOIN capex_lines cl ON cl.id = cpa.cost_item_id
  WHERE cpa.price_line_id = p_price_line_id
    AND cpa.model_id = p_model_id
    AND cpa.cost_type = 'capex'
  
  UNION ALL
  
  -- IMPEX costs
  SELECT 
    'impex'::text as cost_type,
    il.id as cost_item_id,
    il.item_name as cost_item_name,
    cpa.allocation_percentage,
    ARRAY[
      COALESCE(il.cost_year_1, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_2, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_3, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_4, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_5, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_6, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_7, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_8, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_9, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_10, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_11, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_12, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_13, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_14, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_15, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_16, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_17, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_18, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_19, 0) * cpa.allocation_percentage / 100,
      COALESCE(il.cost_year_20, 0) * cpa.allocation_percentage / 100
    ]::numeric[] as yearly_costs
  FROM cost_price_allocations cpa
  JOIN impex_lines il ON il.id = cpa.cost_item_id
  WHERE cpa.price_line_id = p_price_line_id
    AND cpa.model_id = p_model_id
    AND cpa.cost_type = 'impex';
    
END;
$$;