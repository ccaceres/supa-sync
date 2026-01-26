-- Clean up invalid approval requirements with null approver_id
DELETE FROM stage_approval_requirements 
WHERE approver_type IN ('user', 'team', 'role') 
AND approver_id IS NULL;

-- Add a check to prevent future invalid data
CREATE OR REPLACE FUNCTION validate_stage_approval_requirement()
RETURNS TRIGGER AS $$
BEGIN
  -- If approver_type is user, team, or role, approver_id must not be null
  IF NEW.approver_type IN ('user', 'team', 'role') AND NEW.approver_id IS NULL THEN
    RAISE EXCEPTION 'approver_id cannot be null when approver_type is user, team, or role';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_approval_requirement_validity
  BEFORE INSERT OR UPDATE ON stage_approval_requirements
  FOR EACH ROW
  EXECUTE FUNCTION validate_stage_approval_requirement();