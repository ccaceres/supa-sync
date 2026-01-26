-- Create table for LABEX validation reference values
CREATE TABLE labex_validation_references (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES models(id) ON DELETE CASCADE,
  
  -- Reference values from legacy system
  reference_labex_direct NUMERIC(15, 2) NOT NULL,
  reference_direct_fte_input NUMERIC(10, 2) NOT NULL,
  reference_direct_fte_calc NUMERIC(10, 2) NOT NULL,
  
  -- Metadata
  reference_system_name VARCHAR(100) DEFAULT 'Zulu 1',
  validation_year INTEGER DEFAULT 1,
  notes TEXT,
  
  -- Audit fields
  created_by UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Ensure one reference per model
  UNIQUE(model_id)
);

-- Enable RLS
ALTER TABLE labex_validation_references ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view validation references for accessible models"
  ON labex_validation_references FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = labex_validation_references.model_id
      AND can_access_project(auth.uid(), m.project_id)
    )
  );

CREATE POLICY "Users can insert validation references for editable models"
  ON labex_validation_references FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = labex_validation_references.model_id
      AND can_edit_project(auth.uid(), m.project_id)
    )
  );

CREATE POLICY "Users can update validation references for editable models"
  ON labex_validation_references FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = labex_validation_references.model_id
      AND can_edit_project(auth.uid(), m.project_id)
    )
  );

CREATE POLICY "Users can delete validation references for editable models"
  ON labex_validation_references FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = labex_validation_references.model_id
      AND can_edit_project(auth.uid(), m.project_id)
    )
  );

-- Create trigger for updated_at
CREATE TRIGGER update_labex_validation_references_updated_at
  BEFORE UPDATE ON labex_validation_references
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();