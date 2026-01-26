-- Create function to get cost breakdown by type for a price line
CREATE OR REPLACE FUNCTION public.get_cost_breakdown_for_price_line(
  p_price_line_id uuid,
  p_model_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
AS $function$
DECLARE
  labex_direct_costs numeric[] := ARRAY[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
  labex_indirect_costs numeric[] := ARRAY[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
  opex_costs numeric[] := ARRAY[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
  capex_costs numeric[] := ARRAY[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
  impex_costs numeric[] := ARRAY[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
  allocation_record RECORD;
  is_direct boolean;
BEGIN
  -- Process cost allocations from cost_price_allocations table
  FOR allocation_record IN 
    SELECT 
      cpa.allocation_percentage,
      cpa.cost_type,
      cpa.cost_item_id,
      -- Check if it's direct or indirect labor
      COALESCE(dl.price_line_id, '') != '' as is_direct_labor,
      -- labex costs
      COALESCE(dl.yearly_total_cost_1, 0) as labex_cost_1,
      COALESCE(dl.yearly_total_cost_2, 0) as labex_cost_2,
      COALESCE(dl.yearly_total_cost_3, 0) as labex_cost_3,
      COALESCE(dl.yearly_total_cost_4, 0) as labex_cost_4,
      COALESCE(dl.yearly_total_cost_5, 0) as labex_cost_5,
      COALESCE(dl.yearly_total_cost_6, 0) as labex_cost_6,
      COALESCE(dl.yearly_total_cost_7, 0) as labex_cost_7,
      COALESCE(dl.yearly_total_cost_8, 0) as labex_cost_8,
      COALESCE(dl.yearly_total_cost_9, 0) as labex_cost_9,
      COALESCE(dl.yearly_total_cost_10, 0) as labex_cost_10,
      COALESCE(dl.yearly_total_cost_11, 0) as labex_cost_11,
      COALESCE(dl.yearly_total_cost_12, 0) as labex_cost_12,
      COALESCE(dl.yearly_total_cost_13, 0) as labex_cost_13,
      COALESCE(dl.yearly_total_cost_14, 0) as labex_cost_14,
      COALESCE(dl.yearly_total_cost_15, 0) as labex_cost_15,
      COALESCE(dl.yearly_total_cost_16, 0) as labex_cost_16,
      COALESCE(dl.yearly_total_cost_17, 0) as labex_cost_17,
      COALESCE(dl.yearly_total_cost_18, 0) as labex_cost_18,
      COALESCE(dl.yearly_total_cost_19, 0) as labex_cost_19,
      COALESCE(dl.yearly_total_cost_20, 0) as labex_cost_20,
      -- opex costs
      COALESCE(opex.cost_year_1, 0) as opex_cost_1,
      COALESCE(opex.cost_year_2, 0) as opex_cost_2,
      COALESCE(opex.cost_year_3, 0) as opex_cost_3,
      COALESCE(opex.cost_year_4, 0) as opex_cost_4,
      COALESCE(opex.cost_year_5, 0) as opex_cost_5,
      COALESCE(opex.cost_year_6, 0) as opex_cost_6,
      COALESCE(opex.cost_year_7, 0) as opex_cost_7,
      COALESCE(opex.cost_year_8, 0) as opex_cost_8,
      COALESCE(opex.cost_year_9, 0) as opex_cost_9,
      COALESCE(opex.cost_year_10, 0) as opex_cost_10,
      COALESCE(opex.cost_year_11, 0) as opex_cost_11,
      COALESCE(opex.cost_year_12, 0) as opex_cost_12,
      COALESCE(opex.cost_year_13, 0) as opex_cost_13,
      COALESCE(opex.cost_year_14, 0) as opex_cost_14,
      COALESCE(opex.cost_year_15, 0) as opex_cost_15,
      COALESCE(opex.cost_year_16, 0) as opex_cost_16,
      COALESCE(opex.cost_year_17, 0) as opex_cost_17,
      COALESCE(opex.cost_year_18, 0) as opex_cost_18,
      COALESCE(opex.cost_year_19, 0) as opex_cost_19,
      COALESCE(opex.cost_year_20, 0) as opex_cost_20,
      -- capex costs
      COALESCE(cap.cost_year_1, 0) as capex_cost_1,
      COALESCE(cap.cost_year_2, 0) as capex_cost_2,
      COALESCE(cap.cost_year_3, 0) as capex_cost_3,
      COALESCE(cap.cost_year_4, 0) as capex_cost_4,
      COALESCE(cap.cost_year_5, 0) as capex_cost_5,
      COALESCE(cap.cost_year_6, 0) as capex_cost_6,
      COALESCE(cap.cost_year_7, 0) as capex_cost_7,
      COALESCE(cap.cost_year_8, 0) as capex_cost_8,
      COALESCE(cap.cost_year_9, 0) as capex_cost_9,
      COALESCE(cap.cost_year_10, 0) as capex_cost_10,
      COALESCE(cap.cost_year_11, 0) as capex_cost_11,
      COALESCE(cap.cost_year_12, 0) as capex_cost_12,
      COALESCE(cap.cost_year_13, 0) as capex_cost_13,
      COALESCE(cap.cost_year_14, 0) as capex_cost_14,
      COALESCE(cap.cost_year_15, 0) as capex_cost_15,
      COALESCE(cap.cost_year_16, 0) as capex_cost_16,
      COALESCE(cap.cost_year_17, 0) as capex_cost_17,
      COALESCE(cap.cost_year_18, 0) as capex_cost_18,
      COALESCE(cap.cost_year_19, 0) as capex_cost_19,
      COALESCE(cap.cost_year_20, 0) as capex_cost_20,
      -- impex costs (ONLY amortized)
      COALESCE(imp.cost_year_1, 0) as impex_cost_1,
      COALESCE(imp.cost_year_2, 0) as impex_cost_2,
      COALESCE(imp.cost_year_3, 0) as impex_cost_3,
      COALESCE(imp.cost_year_4, 0) as impex_cost_4,
      COALESCE(imp.cost_year_5, 0) as impex_cost_5,
      COALESCE(imp.cost_year_6, 0) as impex_cost_6,
      COALESCE(imp.cost_year_7, 0) as impex_cost_7,
      COALESCE(imp.cost_year_8, 0) as impex_cost_8,
      COALESCE(imp.cost_year_9, 0) as impex_cost_9,
      COALESCE(imp.cost_year_10, 0) as impex_cost_10,
      COALESCE(imp.cost_year_11, 0) as impex_cost_11,
      COALESCE(imp.cost_year_12, 0) as impex_cost_12,
      COALESCE(imp.cost_year_13, 0) as impex_cost_13,
      COALESCE(imp.cost_year_14, 0) as impex_cost_14,
      COALESCE(imp.cost_year_15, 0) as impex_cost_15,
      COALESCE(imp.cost_year_16, 0) as impex_cost_16,
      COALESCE(imp.cost_year_17, 0) as impex_cost_17,
      COALESCE(imp.cost_year_18, 0) as impex_cost_18,
      COALESCE(imp.cost_year_19, 0) as impex_cost_19,
      COALESCE(imp.cost_year_20, 0) as impex_cost_20
    FROM cost_price_allocations cpa
    LEFT JOIN dl_roles dl ON cpa.cost_item_id = dl.id AND cpa.cost_type = 'labex'
    LEFT JOIN opex_lines opex ON cpa.cost_item_id = opex.id AND cpa.cost_type = 'opex'
    LEFT JOIN capex_lines cap ON cpa.cost_item_id = cap.id AND cpa.cost_type = 'capex'
    LEFT JOIN impex_lines imp ON cpa.cost_item_id = imp.id 
      AND cpa.cost_type = 'impex' 
      AND imp.recovery_method = 'amortized'
    WHERE cpa.price_line_id = p_price_line_id
      AND cpa.model_id = p_model_id
  LOOP
    -- Apply allocation percentage and add to appropriate cost type array
    FOR i IN 1..20 LOOP
      IF allocation_record.cost_type = 'labex' THEN
        -- Determine if direct or indirect based on price_line_id
        is_direct := allocation_record.is_direct_labor;
        
        IF is_direct THEN
          labex_direct_costs[i] := labex_direct_costs[i] + (
            CASE i
              WHEN 1 THEN allocation_record.labex_cost_1
              WHEN 2 THEN allocation_record.labex_cost_2
              WHEN 3 THEN allocation_record.labex_cost_3
              WHEN 4 THEN allocation_record.labex_cost_4
              WHEN 5 THEN allocation_record.labex_cost_5
              WHEN 6 THEN allocation_record.labex_cost_6
              WHEN 7 THEN allocation_record.labex_cost_7
              WHEN 8 THEN allocation_record.labex_cost_8
              WHEN 9 THEN allocation_record.labex_cost_9
              WHEN 10 THEN allocation_record.labex_cost_10
              WHEN 11 THEN allocation_record.labex_cost_11
              WHEN 12 THEN allocation_record.labex_cost_12
              WHEN 13 THEN allocation_record.labex_cost_13
              WHEN 14 THEN allocation_record.labex_cost_14
              WHEN 15 THEN allocation_record.labex_cost_15
              WHEN 16 THEN allocation_record.labex_cost_16
              WHEN 17 THEN allocation_record.labex_cost_17
              WHEN 18 THEN allocation_record.labex_cost_18
              WHEN 19 THEN allocation_record.labex_cost_19
              WHEN 20 THEN allocation_record.labex_cost_20
            END
          ) * (allocation_record.allocation_percentage / 100.0);
        ELSE
          labex_indirect_costs[i] := labex_indirect_costs[i] + (
            CASE i
              WHEN 1 THEN allocation_record.labex_cost_1
              WHEN 2 THEN allocation_record.labex_cost_2
              WHEN 3 THEN allocation_record.labex_cost_3
              WHEN 4 THEN allocation_record.labex_cost_4
              WHEN 5 THEN allocation_record.labex_cost_5
              WHEN 6 THEN allocation_record.labex_cost_6
              WHEN 7 THEN allocation_record.labex_cost_7
              WHEN 8 THEN allocation_record.labex_cost_8
              WHEN 9 THEN allocation_record.labex_cost_9
              WHEN 10 THEN allocation_record.labex_cost_10
              WHEN 11 THEN allocation_record.labex_cost_11
              WHEN 12 THEN allocation_record.labex_cost_12
              WHEN 13 THEN allocation_record.labex_cost_13
              WHEN 14 THEN allocation_record.labex_cost_14
              WHEN 15 THEN allocation_record.labex_cost_15
              WHEN 16 THEN allocation_record.labex_cost_16
              WHEN 17 THEN allocation_record.labex_cost_17
              WHEN 18 THEN allocation_record.labex_cost_18
              WHEN 19 THEN allocation_record.labex_cost_19
              WHEN 20 THEN allocation_record.labex_cost_20
            END
          ) * (allocation_record.allocation_percentage / 100.0);
        END IF;
      ELSIF allocation_record.cost_type = 'opex' THEN
        opex_costs[i] := opex_costs[i] + (
          CASE i
            WHEN 1 THEN allocation_record.opex_cost_1
            WHEN 2 THEN allocation_record.opex_cost_2
            WHEN 3 THEN allocation_record.opex_cost_3
            WHEN 4 THEN allocation_record.opex_cost_4
            WHEN 5 THEN allocation_record.opex_cost_5
            WHEN 6 THEN allocation_record.opex_cost_6
            WHEN 7 THEN allocation_record.opex_cost_7
            WHEN 8 THEN allocation_record.opex_cost_8
            WHEN 9 THEN allocation_record.opex_cost_9
            WHEN 10 THEN allocation_record.opex_cost_10
            WHEN 11 THEN allocation_record.opex_cost_11
            WHEN 12 THEN allocation_record.opex_cost_12
            WHEN 13 THEN allocation_record.opex_cost_13
            WHEN 14 THEN allocation_record.opex_cost_14
            WHEN 15 THEN allocation_record.opex_cost_15
            WHEN 16 THEN allocation_record.opex_cost_16
            WHEN 17 THEN allocation_record.opex_cost_17
            WHEN 18 THEN allocation_record.opex_cost_18
            WHEN 19 THEN allocation_record.opex_cost_19
            WHEN 20 THEN allocation_record.opex_cost_20
          END
        ) * (allocation_record.allocation_percentage / 100.0);
      ELSIF allocation_record.cost_type = 'capex' THEN
        capex_costs[i] := capex_costs[i] + (
          CASE i
            WHEN 1 THEN allocation_record.capex_cost_1
            WHEN 2 THEN allocation_record.capex_cost_2
            WHEN 3 THEN allocation_record.capex_cost_3
            WHEN 4 THEN allocation_record.capex_cost_4
            WHEN 5 THEN allocation_record.capex_cost_5
            WHEN 6 THEN allocation_record.capex_cost_6
            WHEN 7 THEN allocation_record.capex_cost_7
            WHEN 8 THEN allocation_record.capex_cost_8
            WHEN 9 THEN allocation_record.capex_cost_9
            WHEN 10 THEN allocation_record.capex_cost_10
            WHEN 11 THEN allocation_record.capex_cost_11
            WHEN 12 THEN allocation_record.capex_cost_12
            WHEN 13 THEN allocation_record.capex_cost_13
            WHEN 14 THEN allocation_record.capex_cost_14
            WHEN 15 THEN allocation_record.capex_cost_15
            WHEN 16 THEN allocation_record.capex_cost_16
            WHEN 17 THEN allocation_record.capex_cost_17
            WHEN 18 THEN allocation_record.capex_cost_18
            WHEN 19 THEN allocation_record.capex_cost_19
            WHEN 20 THEN allocation_record.capex_cost_20
          END
        ) * (allocation_record.allocation_percentage / 100.0);
      ELSIF allocation_record.cost_type = 'impex' THEN
        impex_costs[i] := impex_costs[i] + (
          CASE i
            WHEN 1 THEN allocation_record.impex_cost_1
            WHEN 2 THEN allocation_record.impex_cost_2
            WHEN 3 THEN allocation_record.impex_cost_3
            WHEN 4 THEN allocation_record.impex_cost_4
            WHEN 5 THEN allocation_record.impex_cost_5
            WHEN 6 THEN allocation_record.impex_cost_6
            WHEN 7 THEN allocation_record.impex_cost_7
            WHEN 8 THEN allocation_record.impex_cost_8
            WHEN 9 THEN allocation_record.impex_cost_9
            WHEN 10 THEN allocation_record.impex_cost_10
            WHEN 11 THEN allocation_record.impex_cost_11
            WHEN 12 THEN allocation_record.impex_cost_12
            WHEN 13 THEN allocation_record.impex_cost_13
            WHEN 14 THEN allocation_record.impex_cost_14
            WHEN 15 THEN allocation_record.impex_cost_15
            WHEN 16 THEN allocation_record.impex_cost_16
            WHEN 17 THEN allocation_record.impex_cost_17
            WHEN 18 THEN allocation_record.impex_cost_18
            WHEN 19 THEN allocation_record.impex_cost_19
            WHEN 20 THEN allocation_record.impex_cost_20
          END
        ) * (allocation_record.allocation_percentage / 100.0);
      END IF;
    END LOOP;
  END LOOP;

  -- Add direct labor costs linked via price_line_id (100% allocation as direct)
  FOR allocation_record IN 
    SELECT 
      yearly_total_cost_1, yearly_total_cost_2, yearly_total_cost_3, yearly_total_cost_4, yearly_total_cost_5,
      yearly_total_cost_6, yearly_total_cost_7, yearly_total_cost_8, yearly_total_cost_9, yearly_total_cost_10,
      yearly_total_cost_11, yearly_total_cost_12, yearly_total_cost_13, yearly_total_cost_14, yearly_total_cost_15,
      yearly_total_cost_16, yearly_total_cost_17, yearly_total_cost_18, yearly_total_cost_19, yearly_total_cost_20
    FROM dl_roles 
    WHERE price_line_id = p_price_line_id
      AND model_id = p_model_id
      AND id NOT IN (
        SELECT cost_item_id 
        FROM cost_price_allocations 
        WHERE price_line_id = p_price_line_id 
          AND cost_type = 'labex'
      )
  LOOP
    labex_direct_costs[1] := labex_direct_costs[1] + COALESCE(allocation_record.yearly_total_cost_1, 0);
    labex_direct_costs[2] := labex_direct_costs[2] + COALESCE(allocation_record.yearly_total_cost_2, 0);
    labex_direct_costs[3] := labex_direct_costs[3] + COALESCE(allocation_record.yearly_total_cost_3, 0);
    labex_direct_costs[4] := labex_direct_costs[4] + COALESCE(allocation_record.yearly_total_cost_4, 0);
    labex_direct_costs[5] := labex_direct_costs[5] + COALESCE(allocation_record.yearly_total_cost_5, 0);
    labex_direct_costs[6] := labex_direct_costs[6] + COALESCE(allocation_record.yearly_total_cost_6, 0);
    labex_direct_costs[7] := labex_direct_costs[7] + COALESCE(allocation_record.yearly_total_cost_7, 0);
    labex_direct_costs[8] := labex_direct_costs[8] + COALESCE(allocation_record.yearly_total_cost_8, 0);
    labex_direct_costs[9] := labex_direct_costs[9] + COALESCE(allocation_record.yearly_total_cost_9, 0);
    labex_direct_costs[10] := labex_direct_costs[10] + COALESCE(allocation_record.yearly_total_cost_10, 0);
    labex_direct_costs[11] := labex_direct_costs[11] + COALESCE(allocation_record.yearly_total_cost_11, 0);
    labex_direct_costs[12] := labex_direct_costs[12] + COALESCE(allocation_record.yearly_total_cost_12, 0);
    labex_direct_costs[13] := labex_direct_costs[13] + COALESCE(allocation_record.yearly_total_cost_13, 0);
    labex_direct_costs[14] := labex_direct_costs[14] + COALESCE(allocation_record.yearly_total_cost_14, 0);
    labex_direct_costs[15] := labex_direct_costs[15] + COALESCE(allocation_record.yearly_total_cost_15, 0);
    labex_direct_costs[16] := labex_direct_costs[16] + COALESCE(allocation_record.yearly_total_cost_16, 0);
    labex_direct_costs[17] := labex_direct_costs[17] + COALESCE(allocation_record.yearly_total_cost_17, 0);
    labex_direct_costs[18] := labex_direct_costs[18] + COALESCE(allocation_record.yearly_total_cost_18, 0);
    labex_direct_costs[19] := labex_direct_costs[19] + COALESCE(allocation_record.yearly_total_cost_19, 0);
    labex_direct_costs[20] := labex_direct_costs[20] + COALESCE(allocation_record.yearly_total_cost_20, 0);
  END LOOP;

  -- Return as JSONB
  RETURN jsonb_build_object(
    'labex_direct', labex_direct_costs,
    'labex_indirect', labex_indirect_costs,
    'opex', opex_costs,
    'capex', capex_costs,
    'impex', impex_costs
  );
END;
$function$;