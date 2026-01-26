-- Create teams table with flexible hierarchy (original migration - making idempotent)
CREATE TABLE IF NOT EXISTS public.teams (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR NOT NULL,
    description TEXT,
    parent_team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    level INTEGER NOT NULL DEFAULT 1,
    team_type VARCHAR NOT NULL DEFAULT 'department',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_by UUID REFERENCES auth.users(id) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create team members table
CREATE TABLE IF NOT EXISTS public.team_members (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    role VARCHAR NOT NULL DEFAULT 'member',
    is_approver BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    assigned_by UUID REFERENCES auth.users(id),
    assigned_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE(team_id, user_id)
);

-- Create approval pipelines table
CREATE TABLE IF NOT EXISTS public.approval_pipelines (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_default BOOLEAN NOT NULL DEFAULT false,
    created_by UUID REFERENCES auth.users(id) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create pipeline stages table
CREATE TABLE IF NOT EXISTS public.pipeline_stages (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    pipeline_id UUID REFERENCES public.approval_pipelines(id) ON DELETE CASCADE NOT NULL,
    stage_order INTEGER NOT NULL,
    name VARCHAR NOT NULL,
    description TEXT,
    stage_type VARCHAR NOT NULL DEFAULT 'sequential',
    is_optional BOOLEAN NOT NULL DEFAULT false,
    timeout_hours INTEGER,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE(pipeline_id, stage_order)
);

-- Create stage approval requirements table
CREATE TABLE IF NOT EXISTS public.stage_approval_requirements (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    stage_id UUID REFERENCES public.pipeline_stages(id) ON DELETE CASCADE NOT NULL,
    approver_type VARCHAR NOT NULL,
    approver_id UUID,
    required_count INTEGER NOT NULL DEFAULT 1,
    is_optional BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create pipeline assignment rules table
CREATE TABLE IF NOT EXISTS public.pipeline_assignment_rules (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    pipeline_id UUID REFERENCES public.approval_pipelines(id) ON DELETE CASCADE NOT NULL,
    rule_name VARCHAR NOT NULL,
    conditions JSONB NOT NULL DEFAULT '{}',
    priority INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_by UUID REFERENCES auth.users(id) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create model approvals table
CREATE TABLE IF NOT EXISTS public.model_approvals (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    model_id UUID REFERENCES public.models(id) ON DELETE CASCADE NOT NULL,
    pipeline_id UUID REFERENCES public.approval_pipelines(id) NOT NULL,
    current_stage_id UUID REFERENCES public.pipeline_stages(id),
    status VARCHAR NOT NULL DEFAULT 'pending',
    started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE(model_id)
);

-- Create approval actions table
CREATE TABLE IF NOT EXISTS public.approval_actions (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    model_approval_id UUID REFERENCES public.model_approvals(id) ON DELETE CASCADE NOT NULL,
    stage_id UUID REFERENCES public.pipeline_stages(id) NOT NULL,
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    team_id UUID REFERENCES public.teams(id),
    action VARCHAR NOT NULL,
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS on all tables
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.approval_pipelines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pipeline_stages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stage_approval_requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pipeline_assignment_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.model_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.approval_actions ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for teams
DROP POLICY IF EXISTS "Users can view teams they belong to" ON public.teams;
CREATE POLICY "Users can view teams they belong to" ON public.teams
FOR SELECT USING (
    id IN (
        SELECT team_id FROM public.team_members
        WHERE user_id = auth.uid() AND is_active = true
    ) OR
    has_role(auth.uid(), 'admin'::app_role)
);

DROP POLICY IF EXISTS "Admins can manage teams" ON public.teams;
CREATE POLICY "Admins can manage teams" ON public.teams
FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));

-- Create RLS policies for team members
DROP POLICY IF EXISTS "Users can view team members of their teams" ON public.team_members;
CREATE POLICY "Users can view team members of their teams" ON public.team_members
FOR SELECT USING (
    team_id IN (
        SELECT team_id FROM public.team_members
        WHERE user_id = auth.uid() AND is_active = true
    ) OR
    has_role(auth.uid(), 'admin'::app_role)
);

DROP POLICY IF EXISTS "Team leaders and admins can manage team members" ON public.team_members;
CREATE POLICY "Team leaders and admins can manage team members" ON public.team_members
FOR ALL USING (
    (team_id IN (
        SELECT team_id FROM public.team_members
        WHERE user_id = auth.uid() AND role IN ('leader', 'manager') AND is_active = true
    )) OR
    has_role(auth.uid(), 'admin'::app_role)
);

-- Create RLS policies for approval pipelines
DROP POLICY IF EXISTS "Authenticated users can view active pipelines" ON public.approval_pipelines;
CREATE POLICY "Authenticated users can view active pipelines" ON public.approval_pipelines
FOR SELECT USING (is_active = true OR has_role(auth.uid(), 'admin'::app_role));

DROP POLICY IF EXISTS "Admins and managers can manage pipelines" ON public.approval_pipelines;
CREATE POLICY "Admins and managers can manage pipelines" ON public.approval_pipelines
FOR ALL USING (
    has_role(auth.uid(), 'admin'::app_role) OR
    has_permission(auth.uid(), 'approvals.manage'::permission_type)
);

-- Create RLS policies for pipeline stages
DROP POLICY IF EXISTS "Users can view pipeline stages" ON public.pipeline_stages;
CREATE POLICY "Users can view pipeline stages" ON public.pipeline_stages
FOR SELECT USING (
    pipeline_id IN (
        SELECT id FROM public.approval_pipelines WHERE is_active = true
    ) OR
    has_role(auth.uid(), 'admin'::app_role)
);

DROP POLICY IF EXISTS "Admins and managers can manage pipeline stages" ON public.pipeline_stages;
CREATE POLICY "Admins and managers can manage pipeline stages" ON public.pipeline_stages
FOR ALL USING (
    has_role(auth.uid(), 'admin'::app_role) OR
    has_permission(auth.uid(), 'approvals.manage'::permission_type)
);

-- Create RLS policies for stage approval requirements
DROP POLICY IF EXISTS "Users can view stage requirements" ON public.stage_approval_requirements;
CREATE POLICY "Users can view stage requirements" ON public.stage_approval_requirements
FOR SELECT USING (
    stage_id IN (
        SELECT ps.id FROM public.pipeline_stages ps
        JOIN public.approval_pipelines ap ON ps.pipeline_id = ap.id
        WHERE ap.is_active = true
    ) OR
    has_role(auth.uid(), 'admin'::app_role)
);

DROP POLICY IF EXISTS "Admins and managers can manage stage requirements" ON public.stage_approval_requirements;
CREATE POLICY "Admins and managers can manage stage requirements" ON public.stage_approval_requirements
FOR ALL USING (
    has_role(auth.uid(), 'admin'::app_role) OR
    has_permission(auth.uid(), 'approvals.manage'::permission_type)
);

-- Create RLS policies for pipeline assignment rules
DROP POLICY IF EXISTS "Users can view assignment rules" ON public.pipeline_assignment_rules;
CREATE POLICY "Users can view assignment rules" ON public.pipeline_assignment_rules
FOR SELECT USING (
    pipeline_id IN (
        SELECT id FROM public.approval_pipelines WHERE is_active = true
    ) OR
    has_role(auth.uid(), 'admin'::app_role)
);

DROP POLICY IF EXISTS "Admins and managers can manage assignment rules" ON public.pipeline_assignment_rules;
CREATE POLICY "Admins and managers can manage assignment rules" ON public.pipeline_assignment_rules
FOR ALL USING (
    has_role(auth.uid(), 'admin'::app_role) OR
    has_permission(auth.uid(), 'approvals.manage'::permission_type)
);

-- Create RLS policies for model approvals
DROP POLICY IF EXISTS "Users can view model approvals for accessible projects" ON public.model_approvals;
CREATE POLICY "Users can view model approvals for accessible projects" ON public.model_approvals
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.models m
        WHERE m.id = model_approvals.model_id
        AND can_access_project(auth.uid(), m.project_id)
    )
);

DROP POLICY IF EXISTS "Users can manage model approvals for editable projects" ON public.model_approvals;
CREATE POLICY "Users can manage model approvals for editable projects" ON public.model_approvals
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM public.models m
        WHERE m.id = model_approvals.model_id
        AND can_edit_project(auth.uid(), m.project_id)
    ) OR
    has_role(auth.uid(), 'admin'::app_role)
);

-- Create RLS policies for approval actions
DROP POLICY IF EXISTS "Users can view approval actions for accessible projects" ON public.approval_actions;
CREATE POLICY "Users can view approval actions for accessible projects" ON public.approval_actions
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.model_approvals ma
        JOIN public.models m ON ma.model_id = m.id
        WHERE ma.id = approval_actions.model_approval_id
        AND can_access_project(auth.uid(), m.project_id)
    )
);

DROP POLICY IF EXISTS "Users can create approval actions they are authorized for" ON public.approval_actions;
CREATE POLICY "Users can create approval actions they are authorized for" ON public.approval_actions
FOR INSERT WITH CHECK (
    user_id = auth.uid() AND
    EXISTS (
        SELECT 1 FROM public.model_approvals ma
        JOIN public.models m ON ma.model_id = m.id
        WHERE ma.id = approval_actions.model_approval_id
        AND can_access_project(auth.uid(), m.project_id)
    )
);

-- Create function to update updated_at column
CREATE OR REPLACE FUNCTION public.update_updated_at_pipeline()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
DROP TRIGGER IF EXISTS update_teams_updated_at ON public.teams;
CREATE TRIGGER update_teams_updated_at
    BEFORE UPDATE ON public.teams
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_pipeline();

DROP TRIGGER IF EXISTS update_approval_pipelines_updated_at ON public.approval_pipelines;
CREATE TRIGGER update_approval_pipelines_updated_at
    BEFORE UPDATE ON public.approval_pipelines
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_pipeline();

DROP TRIGGER IF EXISTS update_pipeline_stages_updated_at ON public.pipeline_stages;
CREATE TRIGGER update_pipeline_stages_updated_at
    BEFORE UPDATE ON public.pipeline_stages
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_pipeline();

DROP TRIGGER IF EXISTS update_pipeline_assignment_rules_updated_at ON public.pipeline_assignment_rules;
CREATE TRIGGER update_pipeline_assignment_rules_updated_at
    BEFORE UPDATE ON public.pipeline_assignment_rules
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_pipeline();

DROP TRIGGER IF EXISTS update_model_approvals_updated_at ON public.model_approvals;
CREATE TRIGGER update_model_approvals_updated_at
    BEFORE UPDATE ON public.model_approvals
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_pipeline();

-- Insert default approval pipeline (only if not exists and users exist)
INSERT INTO public.approval_pipelines (name, description, is_default, created_by)
SELECT
    'Standard Approval',
    'Default approval pipeline for models',
    true,
    id
FROM auth.users
WHERE NOT EXISTS (SELECT 1 FROM public.approval_pipelines WHERE name = 'Standard Approval')
LIMIT 1;

-- Insert default stage for the standard pipeline (only if not exists)
INSERT INTO public.pipeline_stages (pipeline_id, stage_order, name, description)
SELECT
    id,
    1,
    'Initial Review',
    'First stage approval for model review'
FROM public.approval_pipelines
WHERE name = 'Standard Approval'
AND NOT EXISTS (
    SELECT 1 FROM public.pipeline_stages ps
    JOIN public.approval_pipelines ap ON ps.pipeline_id = ap.id
    WHERE ap.name = 'Standard Approval' AND ps.name = 'Initial Review'
);

-- Create function to assign default pipeline to models
CREATE OR REPLACE FUNCTION public.assign_default_pipeline_to_model()
RETURNS TRIGGER AS $$
DECLARE
    default_pipeline_id UUID;
BEGIN
    -- Get the default pipeline
    SELECT id INTO default_pipeline_id
    FROM public.approval_pipelines
    WHERE is_default = true AND is_active = true
    LIMIT 1;

    -- Insert model approval record if pipeline exists
    IF default_pipeline_id IS NOT NULL THEN
        INSERT INTO public.model_approvals (model_id, pipeline_id, current_stage_id)
        SELECT
            NEW.id,
            default_pipeline_id,
            ps.id
        FROM public.pipeline_stages ps
        WHERE ps.pipeline_id = default_pipeline_id
        ORDER BY ps.stage_order ASC
        LIMIT 1;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to auto-assign pipeline to new models
DROP TRIGGER IF EXISTS assign_pipeline_to_new_model ON public.models;
CREATE TRIGGER assign_pipeline_to_new_model
    AFTER INSERT ON public.models
    FOR EACH ROW EXECUTE FUNCTION public.assign_default_pipeline_to_model();
