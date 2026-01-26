-- Create enum types for rounds system
CREATE TYPE round_status AS ENUM ('Planning', 'Active', 'Review', 'Completed', 'Cancelled');
CREATE TYPE scorecard_category AS ENUM ('solution_go', 'information_availability', 'operational_review', 'financial_review', 'elt_review');
CREATE TYPE timeline_event_type AS ENUM ('kickoff', 'information_exchange', 'review_start', 'review_complete', 'submission', 'approval');
CREATE TYPE timeline_event_status AS ENUM ('Planned', 'In Progress', 'Completed', 'Delayed');

-- Create rounds table
CREATE TABLE public.rounds (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    project_id UUID NOT NULL,
    round_number INTEGER NOT NULL,
    name VARCHAR NOT NULL,
    description TEXT,
    status round_status NOT NULL DEFAULT 'Planning',
    
    -- Key dates
    solutions_go_date TIMESTAMP WITH TIME ZONE,
    submission_date TIMESTAMP WITH TIME ZONE,
    information_exchange_date TIMESTAMP WITH TIME ZONE,
    kickoff_date TIMESTAMP WITH TIME ZONE,
    
    -- Scoring fields
    governance_score NUMERIC,
    process_adherence_score NUMERIC,
    can_edit_process_score BOOLEAN DEFAULT true,
    process_score_override NUMERIC,
    process_score_notes TEXT,
    
    -- Pipeline assignment
    pipeline_id UUID,
    
    -- Metadata
    created_by UUID NOT NULL,
    updated_by UUID,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    
    -- Constraints
    UNIQUE(project_id, round_number)
);

-- Create round_process_scorecards table
CREATE TABLE public.round_process_scorecards (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    round_id UUID NOT NULL,
    category scorecard_category NOT NULL,
    subcategory VARCHAR NOT NULL,
    max_points NUMERIC NOT NULL DEFAULT 0,
    actual_points NUMERIC NOT NULL DEFAULT 0,
    is_required BOOLEAN NOT NULL DEFAULT false,
    evidence_required BOOLEAN NOT NULL DEFAULT false,
    evidence_provided BOOLEAN NOT NULL DEFAULT false,
    review_date_original DATE,
    review_date_actual DATE,
    approved BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    
    -- Constraints
    UNIQUE(round_id, category, subcategory)
);

-- Create round_timeline_events table
CREATE TABLE public.round_timeline_events (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    round_id UUID NOT NULL,
    event_type timeline_event_type NOT NULL,
    planned_date TIMESTAMP WITH TIME ZONE,
    actual_date TIMESTAMP WITH TIME ZONE,
    responsible_party VARCHAR,
    status timeline_event_status NOT NULL DEFAULT 'Planned',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    
    -- Constraints
    UNIQUE(round_id, event_type)
);

-- Add round_id to models table
ALTER TABLE public.models ADD COLUMN round_id UUID;

-- Create indexes for better performance
CREATE INDEX idx_rounds_project_id ON public.rounds(project_id);
CREATE INDEX idx_rounds_status ON public.rounds(status);
CREATE INDEX idx_round_scorecards_round_id ON public.round_process_scorecards(round_id);
CREATE INDEX idx_round_timeline_round_id ON public.round_timeline_events(round_id);
CREATE INDEX idx_models_round_id ON public.models(round_id);

-- Enable RLS on all new tables
ALTER TABLE public.rounds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.round_process_scorecards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.round_timeline_events ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for rounds
CREATE POLICY "Users can access rounds for accessible projects" 
ON public.rounds FOR SELECT
USING (can_access_project(auth.uid(), project_id));

CREATE POLICY "Users can create rounds for editable projects" 
ON public.rounds FOR INSERT
WITH CHECK (can_edit_project(auth.uid(), project_id));

CREATE POLICY "Users can update rounds for editable projects" 
ON public.rounds FOR UPDATE
USING (can_edit_project(auth.uid(), project_id));

CREATE POLICY "Users can delete rounds for editable projects" 
ON public.rounds FOR DELETE
USING (can_edit_project(auth.uid(), project_id));

-- Create RLS policies for round_process_scorecards
CREATE POLICY "Users can access scorecards for accessible rounds" 
ON public.round_process_scorecards FOR SELECT
USING (EXISTS (
    SELECT 1 FROM public.rounds r 
    WHERE r.id = round_process_scorecards.round_id 
    AND can_access_project(auth.uid(), r.project_id)
));

CREATE POLICY "Users can manage scorecards for editable rounds" 
ON public.round_process_scorecards FOR ALL
USING (EXISTS (
    SELECT 1 FROM public.rounds r 
    WHERE r.id = round_process_scorecards.round_id 
    AND can_edit_project(auth.uid(), r.project_id)
));

-- Create RLS policies for round_timeline_events
CREATE POLICY "Users can access timeline events for accessible rounds" 
ON public.round_timeline_events FOR SELECT
USING (EXISTS (
    SELECT 1 FROM public.rounds r 
    WHERE r.id = round_timeline_events.round_id 
    AND can_access_project(auth.uid(), r.project_id)
));

CREATE POLICY "Users can manage timeline events for editable rounds" 
ON public.round_timeline_events FOR ALL
USING (EXISTS (
    SELECT 1 FROM public.rounds r 
    WHERE r.id = round_timeline_events.round_id 
    AND can_edit_project(auth.uid(), r.project_id)
));

-- Create trigger for updated_at timestamps
CREATE TRIGGER update_rounds_updated_at
    BEFORE UPDATE ON public.rounds
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_round_scorecards_updated_at
    BEFORE UPDATE ON public.round_process_scorecards
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_round_timeline_updated_at
    BEFORE UPDATE ON public.round_timeline_events
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();