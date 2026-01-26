-- Skip recovery lines in bulk rate calculation
-- Recovery lines should only be calculated by Formula Engine via formulaRecoveryCalculation.ts

CREATE OR REPLACE FUNCTION public.bulk_calculate_price_line_rates(
  p_model_id uuid,
  p_price_line_ids uuid[] DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
  price_line_record RECORD;
  volume_record RECORD;
  total_costs numeric[];
  volumes numeric[];
  cost_per_unit numeric;
  calculated_rate numeric;
  margin_decimal numeric;
  rate_updates jsonb;
  success_count integer := 0;
  skip_count integer := 0;
  error_count integer := 0;
  error_messages text[] := '{}';
BEGIN
  -- Iterate through selected price lines
  FOR price_line_record IN 
    SELECT pl.* 
    FROM price_lines pl
    WHERE pl.model_id = p_model_id
      AND (p_price_line_ids IS NULL OR pl.id = ANY(p_price_line_ids))
  LOOP
    BEGIN
      -- Skip recovery lines - they should only be calculated by Formula Engine
      IF price_line_record.pl_category LIKE '%Recovery%' THEN
        skip_count := skip_count + 1;
        CONTINUE;
      END IF;
      
      -- Skip if no margin set
      IF price_line_record.margin_markup_percent IS NULL OR price_line_record.margin_type IS NULL THEN
        skip_count := skip_count + 1;
        CONTINUE;
      END IF;
      
      -- Get aggregated costs using helper function
      total_costs := get_allocated_costs_for_price_line(price_line_record.id, p_model_id);
      
      -- Get volumes from linked volume stream
      IF price_line_record.volume_stream_id IS NULL THEN
        skip_count := skip_count + 1;
        CONTINUE;
      END IF;
      
      SELECT * INTO volume_record
      FROM volumes
      WHERE id = price_line_record.volume_stream_id;
      
      IF NOT FOUND THEN
        skip_count := skip_count + 1;
        CONTINUE;
      END IF;
      
      -- Build volumes array
      volumes := ARRAY[
        COALESCE(volume_record.year_1, 0),
        COALESCE(volume_record.year_2, 0),
        COALESCE(volume_record.year_3, 0),
        COALESCE(volume_record.year_4, 0),
        COALESCE(volume_record.year_5, 0),
        COALESCE(volume_record.year_6, 0),
        COALESCE(volume_record.year_7, 0),
        COALESCE(volume_record.year_8, 0),
        COALESCE(volume_record.year_9, 0),
        COALESCE(volume_record.year_10, 0),
        COALESCE(volume_record.year_11, 0),
        COALESCE(volume_record.year_12, 0),
        COALESCE(volume_record.year_13, 0),
        COALESCE(volume_record.year_14, 0),
        COALESCE(volume_record.year_15, 0),
        COALESCE(volume_record.year_16, 0),
        COALESCE(volume_record.year_17, 0),
        COALESCE(volume_record.year_18, 0),
        COALESCE(volume_record.year_19, 0),
        COALESCE(volume_record.year_20, 0)
      ];
      
      -- Initialize rate updates object
      rate_updates := '{}';
      
      -- Calculate rate for each year
      FOR i IN 1..20 LOOP
        IF volumes[i] = 0 THEN
          rate_updates := rate_updates || jsonb_build_object('rate_' || i, 0);
          CONTINUE;
        END IF;
        
        -- Calculate cost per unit
        cost_per_unit := total_costs[i] / volumes[i];
        
        -- Calculate rate based on margin type
        margin_decimal := price_line_record.margin_markup_percent / 100.0;
        
        IF price_line_record.margin_type = 'Percentage' THEN
          -- Margin formula: cost / (1 - margin%)
          calculated_rate := cost_per_unit / (1 - margin_decimal);
        ELSE
          -- Markup formula: cost * (1 + markup%)
          calculated_rate := cost_per_unit * (1 + margin_decimal);
        END IF;
        
        rate_updates := rate_updates || jsonb_build_object('rate_' || i, calculated_rate);
      END LOOP;
      
      -- Update price_lines with calculated rates
      UPDATE price_lines
      SET 
        rate_1 = COALESCE((rate_updates->>'rate_1')::numeric, rate_1),
        rate_2 = COALESCE((rate_updates->>'rate_2')::numeric, rate_2),
        rate_3 = COALESCE((rate_updates->>'rate_3')::numeric, rate_3),
        rate_4 = COALESCE((rate_updates->>'rate_4')::numeric, rate_4),
        rate_5 = COALESCE((rate_updates->>'rate_5')::numeric, rate_5),
        rate_6 = COALESCE((rate_updates->>'rate_6')::numeric, rate_6),
        rate_7 = COALESCE((rate_updates->>'rate_7')::numeric, rate_7),
        rate_8 = COALESCE((rate_updates->>'rate_8')::numeric, rate_8),
        rate_9 = COALESCE((rate_updates->>'rate_9')::numeric, rate_9),
        rate_10 = COALESCE((rate_updates->>'rate_10')::numeric, rate_10),
        rate_11 = COALESCE((rate_updates->>'rate_11')::numeric, rate_11),
        rate_12 = COALESCE((rate_updates->>'rate_12')::numeric, rate_12),
        rate_13 = COALESCE((rate_updates->>'rate_13')::numeric, rate_13),
        rate_14 = COALESCE((rate_updates->>'rate_14')::numeric, rate_14),
        rate_15 = COALESCE((rate_updates->>'rate_15')::numeric, rate_15),
        rate_16 = COALESCE((rate_updates->>'rate_16')::numeric, rate_16),
        rate_17 = COALESCE((rate_updates->>'rate_17')::numeric, rate_17),
        rate_18 = COALESCE((rate_updates->>'rate_18')::numeric, rate_18),
        rate_19 = COALESCE((rate_updates->>'rate_19')::numeric, rate_19),
        rate_20 = COALESCE((rate_updates->>'rate_20')::numeric, rate_20),
        rates_calculated_at = NOW(),
        updated_at = NOW()
      WHERE id = price_line_record.id;
      
      success_count := success_count + 1;
      
    EXCEPTION WHEN OTHERS THEN
      error_count := error_count + 1;
      error_messages := array_append(error_messages, 
        format('Price line %s: %s', price_line_record.line_name, SQLERRM));
    END;
  END LOOP;
  
  RETURN jsonb_build_object(
    'success', success_count,
    'skipped', skip_count,
    'errors', error_count,
    'error_messages', error_messages
  );
END;
$function$;