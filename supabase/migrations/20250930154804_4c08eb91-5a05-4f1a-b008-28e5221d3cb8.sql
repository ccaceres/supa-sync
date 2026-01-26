-- Remove milestone-related columns from projects table
ALTER TABLE projects 
DROP COLUMN IF EXISTS milestone_tracking_enabled,
DROP COLUMN IF EXISTS milestone_template;

-- Drop the project_milestones table
DROP TABLE IF EXISTS project_milestones CASCADE;

-- Drop the initialize_project_milestones function
DROP FUNCTION IF EXISTS initialize_project_milestones(uuid, varchar);

-- Drop the milestone_status enum if it exists
DROP TYPE IF EXISTS milestone_status CASCADE;
