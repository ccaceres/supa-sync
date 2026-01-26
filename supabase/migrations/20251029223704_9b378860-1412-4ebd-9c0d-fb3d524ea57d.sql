-- Drop existing function
DROP FUNCTION IF EXISTS bulk_calculate_price_line_rates(uuid, uuid[]);

-- Create helper function to aggregate allocated costs for a price line
CREATE OR REPLACE FUNCTION get_allocated_costs_for_price_line(p_price_line_id uuid)
RETURNS NUMERIC[]
LANGUAGE plpgsql
AS $$
DECLARE
  total_costs NUMERIC[] := ARRAY_FILL(0::NUMERIC, ARRAY[20]);
  allocation_record RECORD;
  yearly_costs NUMERIC[];
  allocated_percentage NUMERIC;
  year_idx INTEGER;
BEGIN
  -- Loop through all allocations for this price line
  FOR allocation_record IN 
    SELECT * FROM cost_price_allocations 
    WHERE price_line_id = p_price_line_id
  LOOP
    allocated_percentage := COALESCE(allocation_record.allocation_percentage, 0) / 100.0;
    yearly_costs := NULL;
    
    -- Fetch cost item based on cost_type and extract yearly costs
    IF allocation_record.cost_type = 'opex' THEN
      SELECT ARRAY[
        COALESCE(cost_year_1, 0), COALESCE(cost_year_2, 0), COALESCE(cost_year_3, 0), COALESCE(cost_year_4, 0), COALESCE(cost_year_5, 0),
        COALESCE(cost_year_6, 0), COALESCE(cost_year_7, 0), COALESCE(cost_year_8, 0), COALESCE(cost_year_9, 0), COALESCE(cost_year_10, 0),
        COALESCE(cost_year_11, 0), COALESCE(cost_year_12, 0), COALESCE(cost_year_13, 0), COALESCE(cost_year_14, 0), COALESCE(cost_year_15, 0),
        COALESCE(cost_year_16, 0), COALESCE(cost_year_17, 0), COALESCE(cost_year_18, 0), COALESCE(cost_year_19, 0), COALESCE(cost_year_20, 0)
      ] INTO yearly_costs
      FROM opex_lines WHERE id = allocation_record.cost_item_id;
      
    ELSIF allocation_record.cost_type = 'capex' THEN
      SELECT ARRAY[
        COALESCE(cost_year_1, 0), COALESCE(cost_year_2, 0), COALESCE(cost_year_3, 0), COALESCE(cost_year_4, 0), COALESCE(cost_year_5, 0),
        COALESCE(cost_year_6, 0), COALESCE(cost_year_7, 0), COALESCE(cost_year_8, 0), COALESCE(cost_year_9, 0), COALESCE(cost_year_10, 0),
        COALESCE(cost_year_11, 0), COALESCE(cost_year_12, 0), COALESCE(cost_year_13, 0), COALESCE(cost_year_14, 0), COALESCE(cost_year_15, 0),
        COALESCE(cost_year_16, 0), COALESCE(cost_year_17, 0), COALESCE(cost_year_18, 0), COALESCE(cost_year_19, 0), COALESCE(cost_year_20, 0)
      ] INTO yearly_costs
      FROM capex_lines WHERE id = allocation_record.cost_item_id;
      
    ELSIF allocation_record.cost_type = 'impex' THEN
      SELECT ARRAY[
        COALESCE(cost_year_1, 0), COALESCE(cost_year_2, 0), COALESCE(cost_year_3, 0), COALESCE(cost_year_4, 0), COALESCE(cost_year_5, 0),
        COALESCE(cost_year_6, 0), COALESCE(cost_year_7, 0), COALESCE(cost_year_8, 0), COALESCE(cost_year_9, 0), COALESCE(cost_year_10, 0),
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0  -- IMPEX only has 10 years
      ] INTO yearly_costs
      FROM impex_lines WHERE id = allocation_record.cost_item_id;
      
    ELSIF allocation_record.cost_type = 'labex' THEN
      SELECT ARRAY[
        COALESCE(yearly_total_cost_1, 0), COALESCE(yearly_total_cost_2, 0), COALESCE(yearly_total_cost_3, 0), COALESCE(yearly_total_cost_4, 0), COALESCE(yearly_total_cost_5, 0),
        COALESCE(yearly_total_cost_6, 0), COALESCE(yearly_total_cost_7, 0), COALESCE(yearly_total_cost_8, 0), COALESCE(yearly_total_cost_9, 0), COALESCE(yearly_total_cost_10, 0),
        COALESCE(yearly_total_cost_11, 0), COALESCE(yearly_total_cost_12, 0), COALESCE(yearly_total_cost_13, 0), COALESCE(yearly_total_cost_14, 0), COALESCE(yearly_total_cost_15, 0),
        COALESCE(yearly_total_cost_16, 0), COALESCE(yearly_total_cost_17, 0), COALESCE(yearly_total_cost_18, 0), COALESCE(yearly_total_cost_19, 0), COALESCE(yearly_total_cost_20, 0)
      ] INTO yearly_costs
      FROM dl_roles WHERE id = allocation_record.cost_item_id;
    END IF;
    
    -- Add allocated costs to total
    IF yearly_costs IS NOT NULL THEN
      FOR year_idx IN 1..20 LOOP
        total_costs[year_idx] := total_costs[year_idx] + (yearly_costs[year_idx] * allocated_percentage);
      END LOOP;
    END IF;
  END LOOP;
  
  -- Also add indirect labor costs (100% allocated, linked directly to price_line_id)
  FOR allocation_record IN 
    SELECT 
      yearly_total_cost_1, yearly_total_cost_2, yearly_total_cost_3, yearly_total_cost_4, yearly_total_cost_5,
      yearly_total_cost_6, yearly_total_cost_7, yearly_total_cost_8, yearly_total_cost_9, yearly_total_cost_10,
      yearly_total_cost_11, yearly_total_cost_12, yearly_total_cost_13, yearly_total_cost_14, yearly_total_cost_15,
      yearly_total_cost_16, yearly_total_cost_17, yearly_total_cost_18, yearly_total_cost_19, yearly_total_cost_20
    FROM labex_indirect_labor 
    WHERE price_line_id = p_price_line_id
  LOOP
    total_costs[1] := total_costs[1] + COALESCE(allocation_record.yearly_total_cost_1, 0);
    total_costs[2] := total_costs[2] + COALESCE(allocation_record.yearly_total_cost_2, 0);
    total_costs[3] := total_costs[3] + COALESCE(allocation_record.yearly_total_cost_3, 0);
    total_costs[4] := total_costs[4] + COALESCE(allocation_record.yearly_total_cost_4, 0);
    total_costs[5] := total_costs[5] + COALESCE(allocation_record.yearly_total_cost_5, 0);
    total_costs[6] := total_costs[6] + COALESCE(allocation_record.yearly_total_cost_6, 0);
    total_costs[7] := total_costs[7] + COALESCE(allocation_record.yearly_total_cost_7, 0);
    total_costs[8] := total_costs[8] + COALESCE(allocation_record.yearly_total_cost_8, 0);
    total_costs[9] := total_costs[9] + COALESCE(allocation_record.yearly_total_cost_9, 0);
    total_costs[10] := total_costs[10] + COALESCE(allocation_record.yearly_total_cost_10, 0);
    total_costs[11] := total_costs[11] + COALESCE(allocation_record.yearly_total_cost_11, 0);
    total_costs[12] := total_costs[12] + COALESCE(allocation_record.yearly_total_cost_12, 0);
    total_costs[13] := total_costs[13] + COALESCE(allocation_record.yearly_total_cost_13, 0);
    total_costs[14] := total_costs[14] + COALESCE(allocation_record.yearly_total_cost_14, 0);
    total_costs[15] := total_costs[15] + COALESCE(allocation_record.yearly_total_cost_15, 0);
    total_costs[16] := total_costs[16] + COALESCE(allocation_record.yearly_total_cost_16, 0);
    total_costs[17] := total_costs[17] + COALESCE(allocation_record.yearly_total_cost_17, 0);
    total_costs[18] := total_costs[18] + COALESCE(allocation_record.yearly_total_cost_18, 0);
    total_costs[19] := total_costs[19] + COALESCE(allocation_record.yearly_total_cost_19, 0);
    total_costs[20] := total_costs[20] + COALESCE(allocation_record.yearly_total_cost_20, 0);
  END LOOP;
  
  RETURN total_costs;
END;
$$;

-- Recreate main function with fixed cost aggregation
CREATE OR REPLACE FUNCTION bulk_calculate_price_line_rates(
  p_model_id uuid,
  p_price_line_ids uuid[] DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  price_line_record RECORD;
  volume_record RECORD;
  total_costs NUMERIC[];
  volumes NUMERIC[];
  margin_percent NUMERIC;
  rate NUMERIC;
  cost_per_unit NUMERIC;
  year_idx INTEGER;
  updated_rates JSONB;
  success_count INTEGER := 0;
  failure_count INTEGER := 0;
  error_messages TEXT[] := '{}';
BEGIN
  -- Loop through price lines (filtered by IDs if provided)
  FOR price_line_record IN
    SELECT pl.* 
    FROM price_lines pl
    WHERE pl.model_id = p_model_id
      AND (p_price_line_ids IS NULL OR pl.id = ANY(p_price_line_ids))
  LOOP
    BEGIN
      -- Skip if no margin set
      IF price_line_record.margin_markup_percent IS NULL OR price_line_record.margin_type IS NULL THEN
        CONTINUE;
      END IF;
      
      -- Get aggregated costs using helper function
      total_costs := get_allocated_costs_for_price_line(price_line_record.id);
      
      -- Get volumes from linked volume stream
      IF price_line_record.volume_stream_id IS NULL THEN
        error_messages := array_append(error_messages, 
          format('Price line %s has no volume stream', price_line_record.line_name));
        failure_count := failure_count + 1;
        CONTINUE;
      END IF;
      
      SELECT 
        ARRAY[
          COALESCE(year_1, 0), COALESCE(year_2, 0), COALESCE(year_3, 0), COALESCE(year_4, 0), COALESCE(year_5, 0),
          COALESCE(year_6, 0), COALESCE(year_7, 0), COALESCE(year_8, 0), COALESCE(year_9, 0), COALESCE(year_10, 0),
          COALESCE(year_11, 0), COALESCE(year_12, 0), COALESCE(year_13, 0), COALESCE(year_14, 0), COALESCE(year_15, 0),
          COALESCE(year_16, 0), COALESCE(year_17, 0), COALESCE(year_18, 0), COALESCE(year_19, 0), COALESCE(year_20, 0)
        ] INTO volumes
      FROM volume_streams
      WHERE id = price_line_record.volume_stream_id;
      
      -- Build rates object
      updated_rates := '{}';
      margin_percent := price_line_record.margin_markup_percent;
      
      FOR year_idx IN 1..20 LOOP
        -- Calculate cost per unit
        IF volumes[year_idx] > 0 THEN
          cost_per_unit := total_costs[year_idx] / volumes[year_idx];
        ELSE
          cost_per_unit := 0;
        END IF;
        
        -- Calculate rate based on margin type
        IF cost_per_unit > 0 AND volumes[year_idx] > 0 THEN
          IF price_line_record.margin_type = 'Percentage' THEN
            -- Rate = Cost / (1 - Margin%)
            rate := cost_per_unit / (1 - (margin_percent / 100.0));
          ELSIF price_line_record.margin_type = 'Markup' THEN
            -- Rate = Cost * (1 + Markup%)
            rate := cost_per_unit * (1 + (margin_percent / 100.0));
          ELSE
            rate := 0;
          END IF;
        ELSE
          rate := 0;
        END IF;
        
        updated_rates := jsonb_set(
          updated_rates,
          ARRAY[format('rate_%s', year_idx)],
          to_jsonb(rate)
        );
      END LOOP;
      
      -- Update price line with calculated rates
      UPDATE price_lines
      SET 
        rate_1 = (updated_rates->>'rate_1')::NUMERIC,
        rate_2 = (updated_rates->>'rate_2')::NUMERIC,
        rate_3 = (updated_rates->>'rate_3')::NUMERIC,
        rate_4 = (updated_rates->>'rate_4')::NUMERIC,
        rate_5 = (updated_rates->>'rate_5')::NUMERIC,
        rate_6 = (updated_rates->>'rate_6')::NUMERIC,
        rate_7 = (updated_rates->>'rate_7')::NUMERIC,
        rate_8 = (updated_rates->>'rate_8')::NUMERIC,
        rate_9 = (updated_rates->>'rate_9')::NUMERIC,
        rate_10 = (updated_rates->>'rate_10')::NUMERIC,
        rate_11 = (updated_rates->>'rate_11')::NUMERIC,
        rate_12 = (updated_rates->>'rate_12')::NUMERIC,
        rate_13 = (updated_rates->>'rate_13')::NUMERIC,
        rate_14 = (updated_rates->>'rate_14')::NUMERIC,
        rate_15 = (updated_rates->>'rate_15')::NUMERIC,
        rate_16 = (updated_rates->>'rate_16')::NUMERIC,
        rate_17 = (updated_rates->>'rate_17')::NUMERIC,
        rate_18 = (updated_rates->>'rate_18')::NUMERIC,
        rate_19 = (updated_rates->>'rate_19')::NUMERIC,
        rate_20 = (updated_rates->>'rate_20')::NUMERIC,
        updated_at = now()
      WHERE id = price_line_record.id;
      
      success_count := success_count + 1;
      
    EXCEPTION WHEN OTHERS THEN
      error_messages := array_append(error_messages, 
        format('Error calculating rates for %s: %s', price_line_record.line_name, SQLERRM));
      failure_count := failure_count + 1;
    END;
  END LOOP;
  
  RETURN jsonb_build_object(
    'success', failure_count = 0,
    'successCount', success_count,
    'failureCount', failure_count,
    'errors', error_messages
  );
END;
$$;