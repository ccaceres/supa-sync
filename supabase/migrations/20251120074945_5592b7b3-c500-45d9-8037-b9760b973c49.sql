-- Phase 1B: Fix Admin Access to All Data
-- Ensure admins can see all models, projects, and related data

-- Drop existing restrictive policies on models table and add admin overrides
DROP POLICY IF EXISTS "Admins can view all models" ON models;
DROP POLICY IF EXISTS "Admins can edit all models" ON models;
DROP POLICY IF EXISTS "Admins can delete all models" ON models;

-- Create comprehensive admin policies for models
CREATE POLICY "Admins can view all models"
ON models FOR SELECT
TO authenticated
USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can insert all models"
ON models FOR INSERT
TO authenticated
WITH CHECK (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update all models"
ON models FOR UPDATE
TO authenticated
USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete all models"
ON models FOR DELETE
TO authenticated
USING (has_role(auth.uid(), 'admin'));

-- Same for projects table
DROP POLICY IF EXISTS "Admins can view all projects" ON projects;
DROP POLICY IF EXISTS "Admins can edit all projects" ON projects;
DROP POLICY IF EXISTS "Admins can delete all projects" ON projects;

CREATE POLICY "Admins can view all projects"
ON projects FOR SELECT
TO authenticated
USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can insert all projects"
ON projects FOR INSERT
TO authenticated
WITH CHECK (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update all projects"
ON projects FOR UPDATE
TO authenticated
USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete all projects"
ON projects FOR DELETE
TO authenticated
USING (has_role(auth.uid(), 'admin'));

-- Add admin overrides to all major data tables
-- profiles
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
CREATE POLICY "Admins can view all profiles"
ON profiles FOR SELECT
TO authenticated
USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update all profiles"
ON profiles FOR UPDATE
TO authenticated
USING (has_role(auth.uid(), 'admin'));

-- customers
DROP POLICY IF EXISTS "Admins can view all customers" ON customers;
CREATE POLICY "Admins can view all customers"
ON customers FOR SELECT
TO authenticated
USING (has_role(auth.uid(), 'admin'));

-- rounds
DROP POLICY IF EXISTS "Admins can view all rounds" ON rounds;
CREATE POLICY "Admins can view all rounds"
ON rounds FOR SELECT
TO authenticated
USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can manage all rounds"
ON rounds FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'));

COMMENT ON POLICY "Admins can view all models" ON models IS 
'Admins have full read access to all models regardless of project membership';

COMMENT ON POLICY "Admins can view all projects" ON projects IS 
'Admins have full read access to all projects';

COMMENT ON POLICY "Admins can view all profiles" ON profiles IS 
'Admins can view all user profiles for user management';

COMMENT ON POLICY "Admins can view all customers" ON customers IS 
'Admins can view all customer data for system administration';