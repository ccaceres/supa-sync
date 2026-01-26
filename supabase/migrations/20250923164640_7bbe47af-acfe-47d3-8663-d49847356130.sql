-- Phase 1: Database Schema Setup for Enhanced Labor Role Request System

-- Create enum for labor role status
CREATE TYPE labor_role_status AS ENUM (
    'active',
    'pending_request', 
    'awaiting_hr_input',
    'rejected',
    'draft'
);

-- Create approved job titles lookup table
CREATE TABLE approved_job_titles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR NOT NULL,
    classification VARCHAR NOT NULL CHECK (classification IN ('direct', 'indirect')),
    category VARCHAR NOT NULL,
    is_exempt BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Insert some default job titles
INSERT INTO approved_job_titles (title, classification, category, is_exempt) VALUES
('Production Operator', 'direct', 'Operations', false),
('Machine Operator', 'direct', 'Operations', false),
('Quality Inspector', 'direct', 'Quality', false),
('Maintenance Technician', 'direct', 'Maintenance', false),
('Warehouse Associate', 'direct', 'Logistics', false),
('Production Supervisor', 'indirect', 'Management', true),
('Quality Manager', 'indirect', 'Quality', true),
('Plant Manager', 'indirect', 'Management', true),
('HR Specialist', 'indirect', 'Human Resources', true),
('Finance Analyst', 'indirect', 'Finance', true);

-- Create labor role requests table
CREATE TABLE labor_role_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_id UUID NOT NULL,
    request_type VARCHAR NOT NULL CHECK (request_type IN ('exempt', 'nonexempt')),
    job_title VARCHAR NOT NULL,
    classification VARCHAR NOT NULL CHECK (classification IN ('direct', 'indirect')),
    city VARCHAR,
    country VARCHAR NOT NULL,
    year INTEGER NOT NULL,
    hr_lead_id UUID,
    comments TEXT,
    status labor_role_status NOT NULL DEFAULT 'draft',
    requested_by UUID NOT NULL,
    requested_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    approved_by UUID,
    approved_at TIMESTAMP WITH TIME ZONE,
    rejected_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Add status and request tracking to existing role tables
ALTER TABLE direct_roles ADD COLUMN IF NOT EXISTS status labor_role_status DEFAULT 'active';
ALTER TABLE direct_roles ADD COLUMN IF NOT EXISTS request_id UUID;
ALTER TABLE direct_roles ADD COLUMN IF NOT EXISTS requested_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE direct_roles ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE direct_roles ADD COLUMN IF NOT EXISTS approved_by UUID;

ALTER TABLE salary_roles ADD COLUMN IF NOT EXISTS status labor_role_status DEFAULT 'active';
ALTER TABLE salary_roles ADD COLUMN IF NOT EXISTS request_id UUID;
ALTER TABLE salary_roles ADD COLUMN IF NOT EXISTS requested_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE salary_roles ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE salary_roles ADD COLUMN IF NOT EXISTS approved_by UUID;

-- Create indexes for performance
CREATE INDEX idx_labor_role_requests_model_id ON labor_role_requests(model_id);
CREATE INDEX idx_labor_role_requests_status ON labor_role_requests(status);
CREATE INDEX idx_labor_role_requests_hr_lead ON labor_role_requests(hr_lead_id);
CREATE INDEX idx_direct_roles_status ON direct_roles(status);
CREATE INDEX idx_salary_roles_status ON salary_roles(status);

-- Add foreign key constraints
ALTER TABLE labor_role_requests 
    ADD CONSTRAINT fk_labor_role_requests_model 
    FOREIGN KEY (model_id) REFERENCES models(id) ON DELETE CASCADE;

ALTER TABLE direct_roles 
    ADD CONSTRAINT fk_direct_roles_request 
    FOREIGN KEY (request_id) REFERENCES labor_role_requests(id) ON DELETE SET NULL;

ALTER TABLE salary_roles 
    ADD CONSTRAINT fk_salary_roles_request 
    FOREIGN KEY (request_id) REFERENCES labor_role_requests(id) ON DELETE SET NULL;

-- Enable RLS on new tables
ALTER TABLE approved_job_titles ENABLE ROW LEVEL SECURITY;
ALTER TABLE labor_role_requests ENABLE ROW LEVEL SECURITY;

-- RLS Policies for approved_job_titles
CREATE POLICY "Anyone can view active job titles" ON approved_job_titles 
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage job titles" ON approved_job_titles 
    FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));

-- RLS Policies for labor_role_requests
CREATE POLICY "Users can view requests for accessible models" ON labor_role_requests 
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM models m 
            WHERE m.id = labor_role_requests.model_id 
            AND can_access_project(auth.uid(), m.project_id)
        )
    );

CREATE POLICY "Users can create requests for editable models" ON labor_role_requests 
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM models m 
            WHERE m.id = labor_role_requests.model_id 
            AND can_edit_project(auth.uid(), m.project_id)
        )
    );

CREATE POLICY "HR leads and admins can update requests" ON labor_role_requests 
    FOR UPDATE USING (
        hr_lead_id = auth.uid() OR 
        has_role(auth.uid(), 'admin'::app_role) OR
        (requested_by = auth.uid() AND status = 'draft')
    );

-- Function to check if model has pending HR requests
CREATE OR REPLACE FUNCTION has_pending_hr_requests(p_model_id UUID)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 FROM direct_roles 
        WHERE model_id = p_model_id AND status = 'awaiting_hr_input'
        UNION
        SELECT 1 FROM salary_roles 
        WHERE model_id = p_model_id AND status = 'awaiting_hr_input'
    )
$$;

-- Trigger to update timestamps
CREATE TRIGGER update_labor_role_requests_updated_at
    BEFORE UPDATE ON labor_role_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_approved_job_titles_updated_at
    BEFORE UPDATE ON approved_job_titles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();