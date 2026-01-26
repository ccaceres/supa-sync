-- Duplicate migration - all tables already created by earlier migrations
-- Making this idempotent with IF NOT EXISTS

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

CREATE TABLE IF NOT EXISTS public.stage_approval_requirements (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    stage_id UUID REFERENCES public.pipeline_stages(id) ON DELETE CASCADE NOT NULL,
    approver_type VARCHAR NOT NULL,
    approver_id UUID,
    required_count INTEGER NOT NULL DEFAULT 1,
    is_optional BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

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

-- Enable RLS on all tables (idempotent)
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.approval_pipelines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pipeline_stages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stage_approval_requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pipeline_assignment_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.model_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.approval_actions ENABLE ROW LEVEL SECURITY;
