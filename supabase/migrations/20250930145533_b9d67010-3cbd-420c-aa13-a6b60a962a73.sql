-- Create milestone status enum
CREATE TYPE milestone_status AS ENUM (
  'not_started',
  'in_progress',
  'completed',
  'blocked',
  'not_applicable'
);

-- Create project_milestones table (optional tracking)
CREATE TABLE project_milestones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  milestone_type VARCHAR NOT NULL,
  milestone_name VARCHAR NOT NULL,
  description TEXT,
  status milestone_status NOT NULL DEFAULT 'not_started',
  sequence_order INTEGER NOT NULL DEFAULT 0,
  target_date TIMESTAMPTZ,
  completed_date TIMESTAMPTZ,
  completed_by UUID REFERENCES auth.users(id),
  assigned_to UUID REFERENCES auth.users(id),
  is_enabled BOOLEAN NOT NULL DEFAULT true,
  is_required BOOLEAN NOT NULL DEFAULT false,
  scorecard_category VARCHAR,
  completion_criteria JSONB DEFAULT '[]'::jsonb,
  notes TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add milestone configuration to projects table
ALTER TABLE projects 
ADD COLUMN IF NOT EXISTS milestone_tracking_enabled BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS milestone_template VARCHAR,
ADD COLUMN IF NOT EXISTS milestone_config JSONB DEFAULT '{}'::jsonb;

-- Add qualification category to round_process_scorecards
-- (This is optional and only used if milestone tracking is enabled)

-- Create indexes for performance
CREATE INDEX idx_project_milestones_project_id ON project_milestones(project_id);
CREATE INDEX idx_project_milestones_status ON project_milestones(status);
CREATE INDEX idx_project_milestones_sequence ON project_milestones(project_id, sequence_order);

-- Enable RLS
ALTER TABLE project_milestones ENABLE ROW LEVEL SECURITY;

-- RLS Policies for project_milestones
CREATE POLICY "Users can view milestones for accessible projects"
  ON project_milestones FOR SELECT
  USING (can_access_project(auth.uid(), project_id));

CREATE POLICY "Users can edit milestones for editable projects"
  ON project_milestones FOR ALL
  USING (can_edit_project(auth.uid(), project_id));

-- Trigger for updated_at
CREATE TRIGGER update_project_milestones_updated_at
  BEFORE UPDATE ON project_milestones
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to initialize default milestones for a project
CREATE OR REPLACE FUNCTION initialize_project_milestones(
  p_project_id UUID,
  p_template VARCHAR DEFAULT 'new_business'
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  milestone_data JSONB;
BEGIN
  -- Delete existing milestones if reinitializing
  DELETE FROM project_milestones WHERE project_id = p_project_id;
  
  -- Define milestone templates
  IF p_template = 'new_business' OR p_template = 'existing_business' THEN
    -- Full 6-stage milestone workflow
    milestone_data := '[
      {
        "type": "qualification",
        "name": "Qualification",
        "description": "Commitment of desire to pursue business",
        "order": 1,
        "scorecard_category": "qualification",
        "criteria": ["Customer commitment documented", "Business case outlined", "Initial requirements gathered"]
      },
      {
        "type": "solutions_go",
        "name": "Solutions Go / No-Go",
        "description": "Allocation of engineering resources to project",
        "order": 2,
        "scorecard_category": "solution_go",
        "criteria": ["Engineering resources allocated", "Technical feasibility confirmed", "Solution approach approved"]
      },
      {
        "type": "kickoff",
        "name": "Kickoff",
        "description": "Initial meeting to provide stakeholders context and information",
        "order": 3,
        "scorecard_category": "information_availability",
        "criteria": ["Kickoff meeting completed", "Stakeholders informed", "Project scope communicated"]
      },
      {
        "type": "operational_review",
        "name": "Operational Review",
        "description": "Review and approval of solutioned design",
        "order": 4,
        "scorecard_category": "operational_review",
        "criteria": ["Design reviewed", "Operational requirements validated", "Implementation plan approved"]
      },
      {
        "type": "finance_review",
        "name": "Finance Review",
        "description": "Review and approval of pricing and financial pro formas",
        "order": 5,
        "scorecard_category": "financial_review",
        "criteria": ["Pricing approved", "Financial model validated", "Budget confirmed"]
      },
      {
        "type": "elt_review",
        "name": "ELT Review",
        "description": "Final review and Executive approval prior to customer submission",
        "order": 6,
        "scorecard_category": "elt_review",
        "criteria": ["Executive review completed", "Final approval obtained", "Ready for customer submission"]
      }
    ]'::jsonb;
    
  ELSIF p_template = 'consultative' THEN
    -- Simplified milestone workflow for consultative projects
    milestone_data := '[
      {
        "type": "kickoff",
        "name": "Project Kickoff",
        "description": "Initial project setup and stakeholder alignment",
        "order": 1,
        "criteria": ["Project scope defined", "Stakeholders aligned"]
      },
      {
        "type": "review",
        "name": "Project Review",
        "description": "Review and approval of deliverables",
        "order": 2,
        "criteria": ["Deliverables reviewed", "Approval obtained"]
      }
    ]'::jsonb;
  END IF;
  
  -- Insert milestones
  INSERT INTO project_milestones (
    project_id,
    milestone_type,
    milestone_name,
    description,
    sequence_order,
    scorecard_category,
    completion_criteria,
    is_enabled,
    is_required,
    created_by
  )
  SELECT
    p_project_id,
    item->>'type',
    item->>'name',
    item->>'description',
    (item->>'order')::integer,
    item->>'scorecard_category',
    COALESCE(item->'criteria', '[]'::jsonb),
    true,
    false, -- Not required by default for flexibility
    auth.uid()
  FROM jsonb_array_elements(milestone_data) AS item;
  
  -- Update project to enable milestone tracking
  UPDATE projects
  SET 
    milestone_tracking_enabled = true,
    milestone_template = p_template,
    updated_at = now()
  WHERE id = p_project_id;
END;
$$;