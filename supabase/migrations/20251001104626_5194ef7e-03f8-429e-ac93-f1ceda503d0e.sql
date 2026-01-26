-- Drop trigger first, then recreate function with proper security settings
DROP TRIGGER IF EXISTS check_approval_requirement_validity ON stage_approval_requirements;
DROP FUNCTION IF EXISTS validate_stage_approval_requirement() CASCADE;

CREATE OR REPLACE FUNCTION validate_stage_approval_requirement()
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  -- If approver_type is user, team, or role, approver_id must not be null
  IF NEW.approver_type IN ('user', 'team', 'role') AND NEW.approver_id IS NULL THEN
    RAISE EXCEPTION 'approver_id cannot be null when approver_type is user, team, or role';
  END IF;
  
  RETURN NEW;
END;
$$;

-- Recreate the trigger
CREATE TRIGGER check_approval_requirement_validity
  BEFORE INSERT OR UPDATE ON stage_approval_requirements
  FOR EACH ROW
  EXECUTE FUNCTION validate_stage_approval_requirement();