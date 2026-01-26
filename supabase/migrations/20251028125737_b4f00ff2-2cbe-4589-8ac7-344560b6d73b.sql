-- Clean up orphaned library_object_usage records
DELETE FROM library_object_usage 
WHERE library_object_type = 'Equipment'
  AND model_object_id NOT IN (SELECT id FROM equipment);

DELETE FROM library_object_usage 
WHERE library_object_type = 'NonExemptPosition'
  AND model_object_id NOT IN (SELECT id FROM nonexempt_positions);

DELETE FROM library_object_usage 
WHERE library_object_type = 'ExemptPosition'
  AND model_object_id NOT IN (SELECT id FROM exempt_positions);

DELETE FROM library_object_usage 
WHERE library_object_type = 'DLRole'
  AND model_object_id NOT IN (SELECT id FROM dl_roles);

-- Add foreign key with cascade delete for equipment
-- Note: PostgreSQL doesn't support conditional foreign keys, so we'll handle cleanup via triggers instead

-- Create trigger function to cascade delete library_object_usage on equipment deletion
CREATE OR REPLACE FUNCTION cleanup_library_object_usage()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM library_object_usage
  WHERE model_object_id = OLD.id
    AND library_object_type = 'Equipment';
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_cleanup_equipment_usage
  BEFORE DELETE ON equipment
  FOR EACH ROW
  EXECUTE FUNCTION cleanup_library_object_usage();

-- Create trigger for nonexempt_positions
CREATE OR REPLACE FUNCTION cleanup_nonexempt_position_usage()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM library_object_usage
  WHERE model_object_id = OLD.id
    AND library_object_type = 'NonExemptPosition';
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_cleanup_nonexempt_position_usage
  BEFORE DELETE ON nonexempt_positions
  FOR EACH ROW
  EXECUTE FUNCTION cleanup_nonexempt_position_usage();

-- Create trigger for exempt_positions
CREATE OR REPLACE FUNCTION cleanup_exempt_position_usage()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM library_object_usage
  WHERE model_object_id = OLD.id
    AND library_object_type = 'ExemptPosition';
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_cleanup_exempt_position_usage
  BEFORE DELETE ON exempt_positions
  FOR EACH ROW
  EXECUTE FUNCTION cleanup_exempt_position_usage();

-- Create trigger for dl_roles
CREATE OR REPLACE FUNCTION cleanup_dl_role_usage()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM library_object_usage
  WHERE model_object_id = OLD.id
    AND library_object_type = 'DLRole';
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_cleanup_dl_role_usage
  BEFORE DELETE ON dl_roles
  FOR EACH ROW
  EXECUTE FUNCTION cleanup_dl_role_usage();