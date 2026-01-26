-- Add rates_calculated_at timestamp to price_lines table for tracking when rates were last calculated
ALTER TABLE price_lines 
ADD COLUMN IF NOT EXISTS rates_calculated_at TIMESTAMP WITH TIME ZONE;

-- Update the bulk_calculate_price_line_rates function to set rates_calculated_at
CREATE OR REPLACE FUNCTION bulk_calculate_price_line_rates(
  p_model_id uuid,
  p_price_line_ids uuid[] DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  price_line_record RECORD;
  v_volume_record RECORD;
  v_yearly_costs NUMERIC[];
  v_yearly_volumes NUMERIC[];
  v_cost_per_unit NUMERIC;
  v_final_rate NUMERIC;
  v_success_count INTEGER := 0;
  v_failure_count INTEGER := 0;
  v_errors TEXT[] := ARRAY[]::TEXT[];
BEGIN
  -- If no specific price lines provided, calculate all for the model
  FOR price_line_record IN 
    SELECT pl.* 
    FROM price_lines pl
    WHERE pl.model_id = p_model_id 
    AND (p_price_line_ids IS NULL OR pl.id = ANY(p_price_line_ids))
  LOOP
    BEGIN
      -- Get volume data
      SELECT 
        ARRAY[year_1, year_2, year_3, year_4, year_5, year_6, year_7, year_8, year_9, year_10,
              year_11, year_12, year_13, year_14, year_15, year_16, year_17, year_18, year_19, year_20]
      INTO v_yearly_volumes
      FROM volumes
      WHERE id = price_line_record.volume_stream_id;
      
      IF v_yearly_volumes IS NULL THEN
        v_errors := array_append(v_errors, 'Price line ' || price_line_record.line_name || ': No volume stream found');
        v_failure_count := v_failure_count + 1;
        CONTINUE;
      END IF;
      
      -- Get aggregated costs from all cost allocations
      SELECT 
        ARRAY[
          COALESCE(SUM(cost_year_1), 0), COALESCE(SUM(cost_year_2), 0), COALESCE(SUM(cost_year_3), 0),
          COALESCE(SUM(cost_year_4), 0), COALESCE(SUM(cost_year_5), 0), COALESCE(SUM(cost_year_6), 0),
          COALESCE(SUM(cost_year_7), 0), COALESCE(SUM(cost_year_8), 0), COALESCE(SUM(cost_year_9), 0),
          COALESCE(SUM(cost_year_10), 0), COALESCE(SUM(cost_year_11), 0), COALESCE(SUM(cost_year_12), 0),
          COALESCE(SUM(cost_year_13), 0), COALESCE(SUM(cost_year_14), 0), COALESCE(SUM(cost_year_15), 0),
          COALESCE(SUM(cost_year_16), 0), COALESCE(SUM(cost_year_17), 0), COALESCE(SUM(cost_year_18), 0),
          COALESCE(SUM(cost_year_19), 0), COALESCE(SUM(cost_year_20), 0)
        ]
      INTO v_yearly_costs
      FROM cost_price_allocations
      WHERE price_line_id = price_line_record.id;
      
      -- Calculate rates for each year
      FOR year IN 1..20 LOOP
        v_cost_per_unit := CASE 
          WHEN v_yearly_volumes[year] > 0 THEN v_yearly_costs[year] / v_yearly_volumes[year]
          ELSE 0 
        END;
        
        -- Apply margin/markup
        IF price_line_record.margin_type = 'Percentage' THEN
          -- Margin: rate = cost / (1 - margin%)
          v_final_rate := CASE 
            WHEN COALESCE(price_line_record.margin_markup_percent, 0) < 100 
            THEN v_cost_per_unit / (1 - (COALESCE(price_line_record.margin_markup_percent, 0) / 100.0))
            ELSE v_cost_per_unit 
          END;
        ELSE
          -- Markup: rate = cost * (1 + markup%)
          v_final_rate := v_cost_per_unit * (1 + (COALESCE(price_line_record.margin_markup_percent, 0) / 100.0));
        END IF;
        
        -- Update the specific rate column
        EXECUTE format('UPDATE price_lines SET rate_%s = $1, rates_calculated_at = NOW(), updated_at = NOW() WHERE id = $2', year)
        USING v_final_rate, price_line_record.id;
      END LOOP;
      
      v_success_count := v_success_count + 1;
      
    EXCEPTION WHEN OTHERS THEN
      v_errors := array_append(v_errors, 'Price line ' || price_line_record.line_name || ': ' || SQLERRM);
      v_failure_count := v_failure_count + 1;
    END;
  END LOOP;
  
  RETURN jsonb_build_object(
    'success', v_success_count > 0,
    'success_count', v_success_count,
    'failure_count', v_failure_count,
    'errors', v_errors
  );
END;
$$;