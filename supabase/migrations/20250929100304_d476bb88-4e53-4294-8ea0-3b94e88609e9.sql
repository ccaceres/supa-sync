-- Fix default pipeline constraint issue

-- First, fix the current data by ensuring only one pipeline is marked as default
-- We'll keep the oldest default pipeline and unset others
WITH first_default AS (
  SELECT id 
  FROM approval_pipelines 
  WHERE is_default = true 
  AND is_active = true
  ORDER BY created_at ASC 
  LIMIT 1
)
UPDATE approval_pipelines 
SET is_default = false 
WHERE is_default = true 
  AND id NOT IN (SELECT id FROM first_default);

-- Add a function to automatically handle default pipeline constraint
CREATE OR REPLACE FUNCTION ensure_single_default_pipeline()
RETURNS TRIGGER AS $$
BEGIN
  -- If setting this pipeline as default, unset all others
  IF NEW.is_default = true AND NEW.is_active = true THEN
    UPDATE approval_pipelines 
    SET is_default = false 
    WHERE id != NEW.id 
      AND is_default = true 
      AND is_active = true;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically enforce single default pipeline
DROP TRIGGER IF EXISTS trigger_ensure_single_default_pipeline ON approval_pipelines;
CREATE TRIGGER trigger_ensure_single_default_pipeline
  BEFORE INSERT OR UPDATE ON approval_pipelines
  FOR EACH ROW
  EXECUTE FUNCTION ensure_single_default_pipeline();