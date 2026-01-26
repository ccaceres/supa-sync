-- Create function to sync all labor positions from volume drivers
CREATE OR REPLACE FUNCTION public.sync_all_labor_from_volumes(p_model_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_updated_nonexempt INTEGER := 0;
    v_updated_exempt INTEGER := 0;
    pos_record RECORD;
    volume_value NUMERIC;
    calculated_hours NUMERIC;
    calculated_fte NUMERIC;
BEGIN
    -- Update nonexempt positions (hourly direct labor)
    FOR pos_record IN 
        SELECT np.id, np.driver_ratio, np.upph, v.year_1 as volume_year_1
        FROM nonexempt_positions np
        JOIN volumes v ON np.driver_id = v.id
        WHERE np.model_id = p_model_id
          AND np.driver_id IS NOT NULL
          AND np.auto_calculate_hours = true
          AND v.is_labor_driver = true
    LOOP
        -- Calculate hours based on: (volume × ratio) ÷ UPPH
        IF pos_record.upph IS NOT NULL AND pos_record.upph > 0 THEN
            volume_value := pos_record.volume_year_1 * COALESCE(pos_record.driver_ratio, 1);
            calculated_hours := volume_value / pos_record.upph;
            
            -- Update position with calculated hours for year 1
            UPDATE nonexempt_positions
            SET hours_year_1 = calculated_hours,
                updated_at = NOW()
            WHERE id = pos_record.id;
            
            v_updated_nonexempt := v_updated_nonexempt + 1;
        END IF;
    END LOOP;
    
    -- Update exempt positions (salaried indirect labor FTE)
    FOR pos_record IN 
        SELECT ep.id, ep.driver_ratio, ep.upph, v.year_1 as volume_year_1
        FROM exempt_positions ep
        JOIN volumes v ON ep.driver_id = v.id
        WHERE ep.model_id = p_model_id
          AND ep.driver_id IS NOT NULL
          AND ep.auto_calculate_fte = true
          AND v.is_labor_driver = true
    LOOP
        -- Calculate FTE based on: (volume × ratio) ÷ UPPH ÷ 2080
        IF pos_record.upph IS NOT NULL AND pos_record.upph > 0 THEN
            volume_value := pos_record.volume_year_1 * COALESCE(pos_record.driver_ratio, 1);
            calculated_hours := volume_value / pos_record.upph;
            calculated_fte := calculated_hours / 2080.0;
            
            -- Update position with calculated FTE for year 1
            UPDATE exempt_positions
            SET fte_year_1 = calculated_fte,
                updated_at = NOW()
            WHERE id = pos_record.id;
            
            v_updated_exempt := v_updated_exempt + 1;
        END IF;
    END LOOP;
    
    -- Return summary
    RETURN jsonb_build_object(
        'updated_positions', v_updated_nonexempt + v_updated_exempt,
        'updated_direct_labor', v_updated_nonexempt,
        'updated_indirect_labor', v_updated_exempt,
        'model_id', p_model_id
    );
END;
$$;

COMMENT ON FUNCTION public.sync_all_labor_from_volumes IS 
'Syncs labor position hours/FTE from linked volume drivers. Updates direct labor (hours) and indirect labor (FTE) positions that have auto_calculate enabled.';