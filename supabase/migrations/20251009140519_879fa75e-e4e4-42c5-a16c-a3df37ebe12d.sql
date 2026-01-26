-- Phase 1: Database Foundation - Labor Classification Refactoring
-- Rename tables from Direct/Salary to Nonexempt/Exempt positions

-- ============================================================================
-- STEP 1: Rename Main Model Tables
-- ============================================================================

-- Rename direct_roles to nonexempt_positions
ALTER TABLE direct_roles RENAME TO nonexempt_positions;

-- Rename salary_roles to exempt_positions  
ALTER TABLE salary_roles RENAME TO exempt_positions;

-- ============================================================================
-- STEP 2: Rename Library Tables
-- ============================================================================

ALTER TABLE library_direct_roles RENAME TO library_nonexempt_positions;
ALTER TABLE library_salary_roles RENAME TO library_exempt_positions;

-- ============================================================================
-- STEP 3: Update DL Roles Foreign Key Column Name
-- ============================================================================

ALTER TABLE dl_roles RENAME COLUMN dl_position_id TO nonexempt_position_id;

-- ============================================================================
-- STEP 4: Add Job Title Foreign Keys
-- ============================================================================

-- Add job_title_id to nonexempt_positions (model positions)
ALTER TABLE nonexempt_positions 
  ADD COLUMN job_title_id UUID REFERENCES approved_job_titles(id) ON DELETE SET NULL;

-- Add job_title_id to exempt_positions (model positions)
ALTER TABLE exempt_positions 
  ADD COLUMN job_title_id UUID REFERENCES approved_job_titles(id) ON DELETE SET NULL;

-- Add job_title_id to library_nonexempt_positions
ALTER TABLE library_nonexempt_positions 
  ADD COLUMN job_title_id UUID REFERENCES approved_job_titles(id) ON DELETE SET NULL;

-- Add job_title_id to library_exempt_positions
ALTER TABLE library_exempt_positions 
  ADD COLUMN job_title_id UUID REFERENCES approved_job_titles(id) ON DELETE SET NULL;

-- ============================================================================
-- STEP 5: Clear Existing Data (Fresh Start)
-- ============================================================================

-- Clear model data (CASCADE will handle dependent records)
TRUNCATE TABLE nonexempt_positions CASCADE;
TRUNCATE TABLE exempt_positions CASCADE;
TRUNCATE TABLE dl_roles CASCADE;

-- Clear library data
TRUNCATE TABLE library_nonexempt_positions CASCADE;
TRUNCATE TABLE library_exempt_positions CASCADE;

-- ============================================================================
-- STEP 6: Update RLS Policies for Nonexempt Positions
-- ============================================================================

-- Drop old policies
DROP POLICY IF EXISTS "Users can view direct roles for accessible models" ON nonexempt_positions;
DROP POLICY IF EXISTS "Users can edit direct roles for accessible models" ON nonexempt_positions;

-- Create new policies with updated naming
CREATE POLICY "Users can view nonexempt positions for accessible models" 
  ON nonexempt_positions 
  FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = nonexempt_positions.model_id 
      AND can_access_project(auth.uid(), m.project_id)
    )
  );

CREATE POLICY "Users can edit nonexempt positions for accessible models" 
  ON nonexempt_positions 
  FOR ALL 
  USING (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = nonexempt_positions.model_id 
      AND can_edit_project(auth.uid(), m.project_id)
    )
  );

-- ============================================================================
-- STEP 7: Update RLS Policies for Exempt Positions
-- ============================================================================

-- Drop old policies
DROP POLICY IF EXISTS "Users can view salary roles for accessible models" ON exempt_positions;
DROP POLICY IF EXISTS "Users can edit salary roles for accessible models" ON exempt_positions;

-- Create new policies
CREATE POLICY "Users can view exempt positions for accessible models" 
  ON exempt_positions 
  FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = exempt_positions.model_id 
      AND can_access_project(auth.uid(), m.project_id)
    )
  );

CREATE POLICY "Users can edit exempt positions for accessible models" 
  ON exempt_positions 
  FOR ALL 
  USING (
    EXISTS (
      SELECT 1 FROM models m
      WHERE m.id = exempt_positions.model_id 
      AND can_edit_project(auth.uid(), m.project_id)
    )
  );

-- ============================================================================
-- STEP 8: Update RLS Policies for Library Nonexempt Positions
-- ============================================================================

DROP POLICY IF EXISTS "Authenticated users with library view permission can see direct roles" ON library_nonexempt_positions;
DROP POLICY IF EXISTS "Users can create library direct roles" ON library_nonexempt_positions;
DROP POLICY IF EXISTS "Users can update library direct roles they created" ON library_nonexempt_positions;
DROP POLICY IF EXISTS "Users can delete library direct roles they created" ON library_nonexempt_positions;

CREATE POLICY "Authenticated users with library view permission can see nonexempt positions" 
  ON library_nonexempt_positions 
  FOR SELECT 
  USING (has_permission(auth.uid(), 'library.view'::permission_type));

CREATE POLICY "Users can create library nonexempt positions" 
  ON library_nonexempt_positions 
  FOR INSERT 
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update library nonexempt positions they created" 
  ON library_nonexempt_positions 
  FOR UPDATE 
  USING (auth.uid() = created_by);

CREATE POLICY "Users can delete library nonexempt positions they created" 
  ON library_nonexempt_positions 
  FOR DELETE 
  USING (auth.uid() = created_by);

-- ============================================================================
-- STEP 9: Update RLS Policies for Library Exempt Positions
-- ============================================================================

DROP POLICY IF EXISTS "Authenticated users with library view permission can see salary roles" ON library_exempt_positions;
DROP POLICY IF EXISTS "Users can create library salary roles" ON library_exempt_positions;
DROP POLICY IF EXISTS "Users can update library salary roles they created" ON library_exempt_positions;
DROP POLICY IF EXISTS "Users can delete library salary roles they created" ON library_exempt_positions;

CREATE POLICY "Authenticated users with library view permission can see exempt positions" 
  ON library_exempt_positions 
  FOR SELECT 
  USING (has_permission(auth.uid(), 'library.view'::permission_type));

CREATE POLICY "Users can create library exempt positions" 
  ON library_exempt_positions 
  FOR INSERT 
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update library exempt positions they created" 
  ON library_exempt_positions 
  FOR UPDATE 
  USING (auth.uid() = created_by);

CREATE POLICY "Users can delete library exempt positions they created" 
  ON library_exempt_positions 
  FOR DELETE 
  USING (auth.uid() = created_by);

-- ============================================================================
-- STEP 10: Update Database Functions
-- ============================================================================

-- Update has_pending_hr_requests function
CREATE OR REPLACE FUNCTION public.has_pending_hr_requests(p_model_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $$
  SELECT EXISTS (
    SELECT 1 FROM nonexempt_positions 
    WHERE model_id = p_model_id AND status = 'awaiting_hr_input'
    UNION
    SELECT 1 FROM exempt_positions 
    WHERE model_id = p_model_id AND status = 'awaiting_hr_input'
  )
$$;

-- ============================================================================
-- STEP 11: Add Comments for Documentation
-- ============================================================================

COMMENT ON TABLE nonexempt_positions IS 'Hourly (nonexempt) labor positions - can be Direct or Indirect';
COMMENT ON TABLE exempt_positions IS 'Salaried (exempt) labor positions - can be Direct or Indirect';
COMMENT ON TABLE library_nonexempt_positions IS 'Library templates for nonexempt positions';
COMMENT ON TABLE library_exempt_positions IS 'Library templates for exempt positions';

COMMENT ON COLUMN nonexempt_positions.job_title_id IS 'Link to master job title - determines suggested classification';
COMMENT ON COLUMN exempt_positions.job_title_id IS 'Link to master job title - determines suggested classification';
COMMENT ON COLUMN nonexempt_positions.project IS 'Optional reference to project that triggered this position';
COMMENT ON COLUMN exempt_positions.project IS 'Optional reference to project that triggered this position';

COMMENT ON COLUMN dl_roles.nonexempt_position_id IS 'References nonexempt position (formerly dl_position_id)';