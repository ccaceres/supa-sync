-- Create team_progress_template_items table
CREATE TABLE IF NOT EXISTS public.team_progress_template_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id UUID NOT NULL REFERENCES public.team_progress_templates(id) ON DELETE CASCADE,
  item_name VARCHAR NOT NULL,
  description TEXT,
  category VARCHAR NOT NULL,
  weight NUMERIC NOT NULL DEFAULT 10,
  is_milestone BOOLEAN NOT NULL DEFAULT false,
  is_critical BOOLEAN NOT NULL DEFAULT false,
  target_days_offset INTEGER,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.team_progress_template_items ENABLE ROW LEVEL SECURITY;

-- Create policies for template items
CREATE POLICY "Team members can view their team template items"
  ON public.team_progress_template_items
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.team_progress_templates tpt
      WHERE tpt.id = team_progress_template_items.template_id
      AND (is_member_of_team(tpt.team_id) OR has_role(auth.uid(), 'admin'::app_role))
    )
  );

CREATE POLICY "Admins and team leads can manage template items"
  ON public.team_progress_template_items
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.team_progress_templates tpt
      WHERE tpt.id = team_progress_template_items.template_id
      AND (
        has_role(auth.uid(), 'admin'::app_role) 
        OR (
          is_member_of_team(tpt.team_id) 
          AND EXISTS (
            SELECT 1 FROM team_members
            WHERE team_members.team_id = tpt.team_id
            AND team_members.user_id = auth.uid()
            AND team_members.role IN ('Lead', 'Manager')
          )
        )
      )
    )
  );

-- Create index for performance
CREATE INDEX idx_template_items_template_id ON public.team_progress_template_items(template_id);
CREATE INDEX idx_template_items_sort_order ON public.team_progress_template_items(template_id, sort_order);