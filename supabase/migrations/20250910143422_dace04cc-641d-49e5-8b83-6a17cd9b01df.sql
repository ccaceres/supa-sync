-- Create RLS policies for teams (drop first if exists)
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

-- Create triggers for updated_at (drop first if exists)
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
