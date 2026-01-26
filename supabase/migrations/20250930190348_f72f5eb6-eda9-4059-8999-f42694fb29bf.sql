-- Create project_schedules table for calendar functionality
CREATE TABLE IF NOT EXISTS public.project_schedules (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  scheduled_date DATE NOT NULL,
  review_type VARCHAR NOT NULL CHECK (review_type IN ('Operational', 'Finance', 'ELT')),
  status VARCHAR NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'cancelled', 'rescheduled')),
  notes TEXT,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.project_schedules ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view schedules for accessible projects"
ON public.project_schedules
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.projects p
    WHERE p.id = project_schedules.project_id
    AND can_access_project(auth.uid(), p.id)
  )
);

CREATE POLICY "Users can create schedules for editable projects"
ON public.project_schedules
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.projects p
    WHERE p.id = project_schedules.project_id
    AND can_edit_project(auth.uid(), p.id)
  )
);

CREATE POLICY "Users can update schedules for editable projects"
ON public.project_schedules
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.projects p
    WHERE p.id = project_schedules.project_id
    AND can_edit_project(auth.uid(), p.id)
  )
);

CREATE POLICY "Users can delete schedules for editable projects"
ON public.project_schedules
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.projects p
    WHERE p.id = project_schedules.project_id
    AND can_edit_project(auth.uid(), p.id)
  )
);

-- Create indexes
CREATE INDEX idx_project_schedules_project_id ON public.project_schedules(project_id);
CREATE INDEX idx_project_schedules_scheduled_date ON public.project_schedules(scheduled_date);
CREATE INDEX idx_project_schedules_review_type ON public.project_schedules(review_type);

-- Create trigger for updated_at
CREATE TRIGGER update_project_schedules_updated_at
BEFORE UPDATE ON public.project_schedules
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();