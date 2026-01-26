-- Create team progress templates table
CREATE TABLE public.team_progress_templates (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
  template_name VARCHAR NOT NULL,
  description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  is_default BOOLEAN NOT NULL DEFAULT false,
  applies_to_round_type round_type,
  created_by UUID REFERENCES auth.users(id) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create team progress items table (the actual trackable milestones/deliverables)
CREATE TABLE public.team_progress_items (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  template_id UUID REFERENCES public.team_progress_templates(id) ON DELETE CASCADE,
  round_id UUID REFERENCES public.rounds(id) ON DELETE CASCADE,
  team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE NOT NULL,
  item_name VARCHAR NOT NULL,
  description TEXT,
  category VARCHAR NOT NULL, -- e.g., 'scope_volume', 'process_map', 'pricing_financials'
  weight NUMERIC NOT NULL DEFAULT 1, -- Weight for score calculation
  target_completion_date TIMESTAMP WITH TIME ZONE,
  actual_completion_date TIMESTAMP WITH TIME ZONE,
  status VARCHAR NOT NULL DEFAULT 'not_started', -- 'not_started', 'in_progress', 'completed', 'blocked'
  completion_percentage NUMERIC NOT NULL DEFAULT 0,
  is_milestone BOOLEAN NOT NULL DEFAULT false,
  is_critical BOOLEAN NOT NULL DEFAULT false,
  parent_item_id UUID REFERENCES public.team_progress_items(id),
  display_order INTEGER NOT NULL DEFAULT 0,
  created_by UUID REFERENCES auth.users(id) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  CONSTRAINT valid_completion CHECK (completion_percentage >= 0 AND completion_percentage <= 100)
);

-- Create team progress updates table (audit trail)
CREATE TABLE public.team_progress_updates (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  progress_item_id UUID REFERENCES public.team_progress_items(id) ON DELETE CASCADE NOT NULL,
  updated_by UUID REFERENCES auth.users(id) NOT NULL,
  previous_status VARCHAR,
  new_status VARCHAR NOT NULL,
  previous_completion NUMERIC,
  new_completion NUMERIC NOT NULL,
  notes TEXT,
  attachments JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create team dashboard configurations table
CREATE TABLE public.team_dashboard_configs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE NOT NULL,
  config_name VARCHAR NOT NULL,
  layout JSONB NOT NULL DEFAULT '{}'::jsonb,
  widgets JSONB NOT NULL DEFAULT '[]'::jsonb,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_by UUID REFERENCES auth.users(id) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(team_id, config_name)
);

-- Enable RLS
ALTER TABLE public.team_progress_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_progress_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_progress_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_dashboard_configs ENABLE ROW LEVEL SECURITY;

-- RLS Policies for team_progress_templates
CREATE POLICY "Team members can view their team templates"
  ON public.team_progress_templates FOR SELECT
  USING (
    is_member_of_team(team_id) OR 
    has_role(auth.uid(), 'admin'::app_role)
  );

CREATE POLICY "Admins and team leads can manage templates"
  ON public.team_progress_templates FOR ALL
  USING (
    has_role(auth.uid(), 'admin'::app_role) OR
    (is_member_of_team(team_id) AND EXISTS (
      SELECT 1 FROM team_members 
      WHERE team_id = team_progress_templates.team_id 
      AND user_id = auth.uid() 
      AND role IN ('Lead', 'Manager')
    ))
  );

-- RLS Policies for team_progress_items
CREATE POLICY "Users can view progress items for accessible rounds"
  ON public.team_progress_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM rounds r
      WHERE r.id = team_progress_items.round_id
      AND can_access_project(auth.uid(), r.project_id)
    )
  );

CREATE POLICY "Team members can update their progress items"
  ON public.team_progress_items FOR UPDATE
  USING (
    is_member_of_team(team_id) AND EXISTS (
      SELECT 1 FROM rounds r
      WHERE r.id = team_progress_items.round_id
      AND can_edit_project(auth.uid(), r.project_id)
    )
  );

CREATE POLICY "Team members can create progress items"
  ON public.team_progress_items FOR INSERT
  WITH CHECK (
    is_member_of_team(team_id) AND EXISTS (
      SELECT 1 FROM rounds r
      WHERE r.id = team_progress_items.round_id
      AND can_edit_project(auth.uid(), r.project_id)
    )
  );

CREATE POLICY "Admins can delete progress items"
  ON public.team_progress_items FOR DELETE
  USING (has_role(auth.uid(), 'admin'::app_role));

-- RLS Policies for team_progress_updates
CREATE POLICY "Users can view updates for accessible rounds"
  ON public.team_progress_updates FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM team_progress_items tpi
      JOIN rounds r ON r.id = tpi.round_id
      WHERE tpi.id = team_progress_updates.progress_item_id
      AND can_access_project(auth.uid(), r.project_id)
    )
  );

CREATE POLICY "Team members can create updates"
  ON public.team_progress_updates FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM team_progress_items tpi
      WHERE tpi.id = team_progress_updates.progress_item_id
      AND is_member_of_team(tpi.team_id)
    )
  );

-- RLS Policies for team_dashboard_configs
CREATE POLICY "Team members can view their dashboard configs"
  ON public.team_dashboard_configs FOR SELECT
  USING (
    is_member_of_team(team_id) OR 
    has_role(auth.uid(), 'admin'::app_role)
  );

CREATE POLICY "Team leads and admins can manage dashboard configs"
  ON public.team_dashboard_configs FOR ALL
  USING (
    has_role(auth.uid(), 'admin'::app_role) OR
    (is_member_of_team(team_id) AND EXISTS (
      SELECT 1 FROM team_members 
      WHERE team_id = team_dashboard_configs.team_id 
      AND user_id = auth.uid() 
      AND role IN ('Lead', 'Manager')
    ))
  );

-- Create indexes for performance
CREATE INDEX idx_team_progress_items_round ON team_progress_items(round_id);
CREATE INDEX idx_team_progress_items_team ON team_progress_items(team_id);
CREATE INDEX idx_team_progress_items_template ON team_progress_items(template_id);
CREATE INDEX idx_team_progress_items_status ON team_progress_items(status);
CREATE INDEX idx_team_progress_updates_item ON team_progress_updates(progress_item_id);
CREATE INDEX idx_team_dashboard_configs_team ON team_dashboard_configs(team_id);

-- Create trigger to update updated_at
CREATE TRIGGER update_team_progress_templates_updated_at
  BEFORE UPDATE ON public.team_progress_templates
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_team_progress_items_updated_at
  BEFORE UPDATE ON public.team_progress_items
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_team_dashboard_configs_updated_at
  BEFORE UPDATE ON public.team_dashboard_configs
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();