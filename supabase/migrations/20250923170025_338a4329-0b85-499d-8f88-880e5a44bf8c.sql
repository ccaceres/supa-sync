-- Add HR role to existing app_role enum
ALTER TYPE app_role ADD VALUE IF NOT EXISTS 'hr_lead';

-- Add HR-specific permissions to existing permission_type enum
ALTER TYPE permission_type ADD VALUE IF NOT EXISTS 'labor_requests.approve';
ALTER TYPE permission_type ADD VALUE IF NOT EXISTS 'labor_requests.manage';
ALTER TYPE permission_type ADD VALUE IF NOT EXISTS 'hr.view_all_requests';

-- NOTE: Cannot INSERT using new enum values in the same transaction
-- The role permissions INSERT has been moved to a later migration

-- Add salary roles table for salary role requests
CREATE TABLE IF NOT EXISTS salary_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_id UUID NOT NULL,
    role_name VARCHAR NOT NULL,
    annual_salary NUMERIC DEFAULT 0,
    schedule_id UUID,
    library_source_id UUID,
    status labor_role_status DEFAULT 'active',
    request_id UUID,
    requested_at TIMESTAMP WITH TIME ZONE,
    approved_at TIMESTAMP WITH TIME ZONE,
    approved_by UUID,
    fte_year_1 NUMERIC DEFAULT 0,
    fte_year_2 NUMERIC DEFAULT 0,
    fte_year_3 NUMERIC DEFAULT 0,
    fte_year_4 NUMERIC DEFAULT 0,
    fte_year_5 NUMERIC DEFAULT 0,
    fte_year_6 NUMERIC DEFAULT 0,
    fte_year_7 NUMERIC DEFAULT 0,
    fte_year_8 NUMERIC DEFAULT 0,
    fte_year_9 NUMERIC DEFAULT 0,
    fte_year_10 NUMERIC DEFAULT 0,
    is_schedule_overridden BOOLEAN DEFAULT false,
    is_salary_overridden BOOLEAN DEFAULT false,
    local_version INTEGER DEFAULT 1,
    override_fields JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable RLS on salary_roles
ALTER TABLE salary_roles ENABLE ROW LEVEL SECURITY;

-- RLS policies for salary_roles
DROP POLICY IF EXISTS "Users can view salary roles for accessible models" ON salary_roles;
CREATE POLICY "Users can view salary roles for accessible models"
ON salary_roles FOR SELECT
USING (EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = salary_roles.model_id
    AND can_access_project(auth.uid(), m.project_id)
));

DROP POLICY IF EXISTS "Users can edit salary roles for accessible models" ON salary_roles;
CREATE POLICY "Users can edit salary roles for accessible models"
ON salary_roles FOR ALL
USING (EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = salary_roles.model_id
    AND can_edit_project(auth.uid(), m.project_id)
));

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_salary_roles_model_id ON salary_roles(model_id);
CREATE INDEX IF NOT EXISTS idx_salary_roles_status ON salary_roles(status);
CREATE INDEX IF NOT EXISTS idx_salary_roles_request_id ON salary_roles(request_id);
