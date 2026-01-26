-- Add "Superseded" status to support single approved model per project constraint
-- This status will be automatically assigned to previously approved models when a new model is approved

-- Note: We don't need to modify the models table structure as the status column already exists
-- We just need to document that "Superseded" is now a valid status value

-- Add a database function to ensure only one approved model per project
CREATE OR REPLACE FUNCTION ensure_single_approved_model()
RETURNS TRIGGER AS $$
BEGIN
    -- If the model is being set to 'Approved' status
    IF NEW.status = 'Approved' AND (OLD.status IS NULL OR OLD.status != 'Approved') THEN
        -- Set all other approved models in the same project to 'Superseded'
        UPDATE models 
        SET status = 'Superseded', 
            updated_at = NOW()
        WHERE project_id = NEW.project_id 
          AND id != NEW.id 
          AND status = 'Approved';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically enforce single approved model constraint
CREATE TRIGGER trigger_ensure_single_approved_model
    BEFORE UPDATE ON models
    FOR EACH ROW
    EXECUTE FUNCTION ensure_single_approved_model();