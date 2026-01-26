-- Function to clear all quantity overrides for a given model
CREATE OR REPLACE FUNCTION clear_opex_quantity_overrides(p_model_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  rows_updated INTEGER;
BEGIN
  -- Update all opex_lines for this model, setting all quantity overrides to NULL
  UPDATE opex_lines
  SET 
    quantity_override_year_1 = NULL,
    quantity_override_year_2 = NULL,
    quantity_override_year_3 = NULL,
    quantity_override_year_4 = NULL,
    quantity_override_year_5 = NULL,
    quantity_override_year_6 = NULL,
    quantity_override_year_7 = NULL,
    quantity_override_year_8 = NULL,
    quantity_override_year_9 = NULL,
    quantity_override_year_10 = NULL,
    quantity_override_year_11 = NULL,
    quantity_override_year_12 = NULL,
    quantity_override_year_13 = NULL,
    quantity_override_year_14 = NULL,
    quantity_override_year_15 = NULL,
    quantity_override_year_16 = NULL,
    quantity_override_year_17 = NULL,
    quantity_override_year_18 = NULL,
    quantity_override_year_19 = NULL,
    quantity_override_year_20 = NULL,
    updated_at = NOW()
  WHERE model_id = p_model_id;
  
  GET DIAGNOSTICS rows_updated = ROW_COUNT;
  RETURN rows_updated;
END;
$$;

-- Add comment
COMMENT ON FUNCTION clear_opex_quantity_overrides IS 'Clears all quantity overrides for opex lines in a given model';