-- Add database constraint to prevent manual "Approved" status
-- Approved status can only be set through proper approval workflow

-- Create function to validate round status transitions
CREATE OR REPLACE FUNCTION validate_round_status_transition()
RETURNS TRIGGER AS $$
BEGIN
  -- Allow Approved status only if it's being set by the approval workflow
  -- (we detect this by checking if approval_date is also being set)
  IF NEW.status = 'Approved' AND OLD.status != 'Approved' THEN
    IF NEW.approval_date IS NULL OR NEW.approval_date = OLD.approval_date THEN
      RAISE EXCEPTION 'Cannot manually set round status to "Approved". Use the approval workflow instead.';
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to validate status transitions on update
DROP TRIGGER IF EXISTS validate_round_status_trigger ON rounds;
CREATE TRIGGER validate_round_status_trigger
  BEFORE UPDATE ON rounds
  FOR EACH ROW
  EXECUTE FUNCTION validate_round_status_transition();

-- Add comment explaining the constraint
COMMENT ON FUNCTION validate_round_status_transition() IS 
  'Prevents manual setting of Approved status. Approved status can only be set through approval workflow which also sets approval_date.';