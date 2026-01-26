-- Add constraint to ensure only one lead model per round
CREATE UNIQUE INDEX idx_unique_lead_model_per_round 
ON models (round_id) 
WHERE is_lead = true;

-- Add comment explaining the lead model concept
COMMENT ON COLUMN models.is_lead IS 'Designates the lead model for a round. Only one model per round can be the lead model, representing the most current solution.';

-- Add function to set a model as lead (automatically unsets other leads in the same round)
CREATE OR REPLACE FUNCTION set_lead_model(p_model_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_round_id uuid;
BEGIN
  -- Get the round_id of the target model
  SELECT round_id INTO v_round_id
  FROM models
  WHERE id = p_model_id;
  
  IF v_round_id IS NULL THEN
    RAISE EXCEPTION 'Model not found or has no round_id';
  END IF;
  
  -- Unset all lead models in this round
  UPDATE models
  SET is_lead = false, updated_at = NOW()
  WHERE round_id = v_round_id AND is_lead = true;
  
  -- Set the target model as lead
  UPDATE models
  SET is_lead = true, updated_at = NOW()
  WHERE id = p_model_id;
END;
$$;

-- Add trigger to automatically set first model in a round as lead
CREATE OR REPLACE FUNCTION auto_set_first_model_as_lead()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- If this is the first model in the round, set it as lead
  IF NOT EXISTS (
    SELECT 1 FROM models 
    WHERE round_id = NEW.round_id 
    AND id != NEW.id
  ) THEN
    NEW.is_lead = true;
  END IF;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_auto_set_first_model_as_lead
BEFORE INSERT ON models
FOR EACH ROW
EXECUTE FUNCTION auto_set_first_model_as_lead();

-- Add approval_date to rounds table for tracking when rounds are approved
ALTER TABLE rounds
ADD COLUMN IF NOT EXISTS approval_date timestamp with time zone,
ADD COLUMN IF NOT EXISTS approved_by uuid REFERENCES auth.users(id);

COMMENT ON COLUMN rounds.approval_date IS 'Date when the round was approved';
COMMENT ON COLUMN rounds.approved_by IS 'User who approved the round';