-- Drop existing restrictive policies on models table
DROP POLICY IF EXISTS "Users can create models in their projects" ON models;
DROP POLICY IF EXISTS "Users can update models in their projects" ON models;
DROP POLICY IF EXISTS "Users can delete models in their projects" ON models;

-- Create new policies using can_access_project for consistency with SELECT policy
CREATE POLICY "Users can create models in accessible projects"
ON models FOR INSERT
WITH CHECK (can_access_project(auth.uid(), project_id));

CREATE POLICY "Users can update models in accessible projects"
ON models FOR UPDATE
USING (can_access_project(auth.uid(), project_id));

CREATE POLICY "Users can delete models in accessible projects"
ON models FOR DELETE
USING (can_access_project(auth.uid(), project_id));

-- Add comment for future reference
COMMENT ON POLICY "Users can create models in accessible projects" ON models IS
'Allows users to create models in any project they have access to via project_assignments table, not just projects they created';