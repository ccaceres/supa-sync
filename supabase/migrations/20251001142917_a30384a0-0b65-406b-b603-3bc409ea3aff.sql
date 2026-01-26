-- Create function to atomically reorder pipeline stages
-- This avoids unique constraint violations by updating all stages in a single transaction
CREATE OR REPLACE FUNCTION public.reorder_pipeline_stages(
  p_pipeline_id uuid,
  p_stage_orders jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  stage_record jsonb;
BEGIN
  -- First, temporarily set all stage orders to negative values to avoid conflicts
  UPDATE pipeline_stages
  SET stage_order = -stage_order - 1000
  WHERE pipeline_id = p_pipeline_id;
  
  -- Then update each stage to its final order
  FOR stage_record IN SELECT * FROM jsonb_array_elements(p_stage_orders)
  LOOP
    UPDATE pipeline_stages
    SET stage_order = (stage_record->>'stage_order')::integer
    WHERE id = (stage_record->>'id')::uuid
    AND pipeline_id = p_pipeline_id;
  END LOOP;
END;
$$;