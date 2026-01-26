-- Function to ensure only one active round per project
CREATE OR REPLACE FUNCTION public.ensure_single_active_round()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- If setting this round to Active status
  IF NEW.status = 'Active' AND (OLD.status IS NULL OR OLD.status != 'Active') THEN
    -- Check if another active round exists for this project
    IF EXISTS (
      SELECT 1 
      FROM rounds 
      WHERE project_id = NEW.project_id 
        AND id != NEW.id 
        AND status = 'Active'
    ) THEN
      RAISE EXCEPTION 'Only one round can be Active per project. Please change the current active round status to "On Hold", "Approved", or "Cancel" before activating this round.';
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;

-- Create trigger to enforce single active round
DROP TRIGGER IF EXISTS enforce_single_active_round ON rounds;
CREATE TRIGGER enforce_single_active_round
  BEFORE INSERT OR UPDATE ON rounds
  FOR EACH ROW
  EXECUTE FUNCTION public.ensure_single_active_round();