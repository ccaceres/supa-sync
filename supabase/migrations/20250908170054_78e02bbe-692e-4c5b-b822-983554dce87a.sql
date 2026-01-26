-- Enhance library_object_usage table to support full linking system
ALTER TABLE library_object_usage 
ADD COLUMN library_version INTEGER DEFAULT 1,
ADD COLUMN local_version INTEGER DEFAULT 1,
ADD COLUMN linked_by UUID REFERENCES auth.users(id),
ADD COLUMN sync_status VARCHAR(50) DEFAULT 'synced',
ADD COLUMN overridden_fields JSONB DEFAULT '{}',
ADD COLUMN custom_values JSONB DEFAULT '{}',
ADD COLUMN notes TEXT,
ADD COLUMN linked_at TIMESTAMPTZ DEFAULT NOW();

-- Add indexes for performance
CREATE INDEX idx_library_usage_sync_status ON library_object_usage(sync_status);
CREATE INDEX idx_library_usage_model_type ON library_object_usage(model_id, library_object_type);

-- Enhance model tables with override tracking
ALTER TABLE direct_roles 
ADD COLUMN is_rate_overridden BOOLEAN DEFAULT FALSE,
ADD COLUMN is_schedule_overridden BOOLEAN DEFAULT FALSE,
ADD COLUMN override_fields JSONB DEFAULT '{}',
ADD COLUMN local_version INTEGER DEFAULT 1;

ALTER TABLE salary_roles 
ADD COLUMN is_salary_overridden BOOLEAN DEFAULT FALSE,
ADD COLUMN is_schedule_overridden BOOLEAN DEFAULT FALSE, 
ADD COLUMN override_fields JSONB DEFAULT '{}',
ADD COLUMN local_version INTEGER DEFAULT 1;

ALTER TABLE equipment 
ADD COLUMN is_cost_overridden BOOLEAN DEFAULT FALSE,
ADD COLUMN is_depreciation_overridden BOOLEAN DEFAULT FALSE,
ADD COLUMN override_fields JSONB DEFAULT '{}',
ADD COLUMN local_version INTEGER DEFAULT 1;

-- Create audit table for tracking changes
CREATE TABLE object_link_audit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_id UUID NOT NULL,
    object_type VARCHAR(50) NOT NULL,
    library_object_id UUID,
    local_object_id UUID,
    action VARCHAR(50) NOT NULL, -- 'linked', 'updated', 'synced', 'unlinked', 'overridden'
    user_id UUID REFERENCES auth.users(id),
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    old_values JSONB,
    new_values JSONB,
    notes TEXT
);

-- Enable RLS on audit table
ALTER TABLE object_link_audit ENABLE ROW LEVEL SECURITY;

-- Create policy for audit table - users can view audit logs for their models
CREATE POLICY "Users can view audit logs for accessible models" ON object_link_audit
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM models m 
        JOIN projects p ON m.project_id = p.id 
        WHERE m.id = object_link_audit.model_id 
        AND p.created_by = auth.uid()
    )
);

-- Add indexes for audit table
CREATE INDEX idx_audit_model_object ON object_link_audit(model_id, object_type);
CREATE INDEX idx_audit_timestamp ON object_link_audit(timestamp DESC);

-- Create function to automatically track linking operations
CREATE OR REPLACE FUNCTION track_object_link_audit()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert audit record for INSERT operations
    IF TG_OP = 'INSERT' THEN
        INSERT INTO object_link_audit (
            model_id, object_type, library_object_id, local_object_id,
            action, user_id, new_values
        ) VALUES (
            NEW.model_id, NEW.library_object_type, NEW.library_object_id, NEW.model_object_id,
            'linked', auth.uid(), row_to_json(NEW)
        );
        RETURN NEW;
    END IF;
    
    -- Insert audit record for UPDATE operations  
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO object_link_audit (
            model_id, object_type, library_object_id, local_object_id,
            action, user_id, old_values, new_values
        ) VALUES (
            NEW.model_id, NEW.library_object_type, NEW.library_object_id, NEW.model_object_id,
            'updated', auth.uid(), row_to_json(OLD), row_to_json(NEW)
        );
        RETURN NEW;
    END IF;
    
    -- Insert audit record for DELETE operations
    IF TG_OP = 'DELETE' THEN
        INSERT INTO object_link_audit (
            model_id, object_type, library_object_id, local_object_id,
            action, user_id, old_values
        ) VALUES (
            OLD.model_id, OLD.library_object_type, OLD.library_object_id, OLD.model_object_id,
            'unlinked', auth.uid(), row_to_json(OLD)
        );
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Create trigger for audit logging
CREATE TRIGGER trigger_library_usage_audit
AFTER INSERT OR UPDATE OR DELETE ON library_object_usage
FOR EACH ROW EXECUTE FUNCTION track_object_link_audit();