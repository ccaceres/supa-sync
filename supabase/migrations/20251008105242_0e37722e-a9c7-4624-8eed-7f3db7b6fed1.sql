-- Create round_approver_designations table
CREATE TABLE public.round_approver_designations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  round_id UUID NOT NULL REFERENCES public.rounds(id) ON DELETE CASCADE,
  business_role VARCHAR NOT NULL,
  designated_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  is_required BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(round_id, business_role)
);

-- Enable RLS
ALTER TABLE public.round_approver_designations ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view approver designations for accessible rounds"
ON public.round_approver_designations
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.rounds r
    WHERE r.id = round_approver_designations.round_id
    AND can_access_project(auth.uid(), r.project_id)
  )
);

CREATE POLICY "Users can create approver designations for editable rounds"
ON public.round_approver_designations
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.rounds r
    WHERE r.id = round_approver_designations.round_id
    AND can_edit_project(auth.uid(), r.project_id)
  )
);

CREATE POLICY "Users can update approver designations for editable rounds"
ON public.round_approver_designations
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.rounds r
    WHERE r.id = round_approver_designations.round_id
    AND can_edit_project(auth.uid(), r.project_id)
  )
);

CREATE POLICY "Users can delete approver designations for editable rounds"
ON public.round_approver_designations
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.rounds r
    WHERE r.id = round_approver_designations.round_id
    AND can_edit_project(auth.uid(), r.project_id)
  )
);

-- Add index for performance
CREATE INDEX idx_round_approver_designations_round_id ON public.round_approver_designations(round_id);
CREATE INDEX idx_round_approver_designations_user_id ON public.round_approver_designations(designated_user_id);

-- Add trigger for updated_at
CREATE TRIGGER update_round_approver_designations_updated_at
BEFORE UPDATE ON public.round_approver_designations
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Insert system setting for required approver roles
INSERT INTO public.system_settings (setting_key, category, description, setting_value, data_type, is_public)
VALUES (
  'required_round_approver_roles',
  'rounds',
  'Required business role designations for round creation',
  '[
    {"key": "ops_approver", "label": "Ops Approver", "required": true},
    {"key": "finance_approver", "label": "Finance Approver", "required": true},
    {"key": "svp_solutions", "label": "SVP, Solutions, Engineering & Optimization", "required": true},
    {"key": "svp_ams_operations", "label": "SVP, AMS Operations", "required": true},
    {"key": "svp_south_region", "label": "SVP, South Region", "required": true},
    {"key": "svp_west_region", "label": "SVP, West Region", "required": true},
    {"key": "svp_central_region", "label": "SVP, Central Region", "required": true},
    {"key": "svp_east_region", "label": "SVP, East Region", "required": true},
    {"key": "svp_canada", "label": "SVP, Canada", "required": true},
    {"key": "president_coo", "label": "President & COO", "required": true},
    {"key": "ceo", "label": "CEO", "required": true}
  ]'::jsonb,
  'json',
  true
)
ON CONFLICT (setting_key) DO NOTHING;