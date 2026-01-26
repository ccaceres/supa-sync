-- Add foreign key constraint for rounds.project_id -> projects.id
-- This enables PostgREST to perform joins between rounds and projects tables

-- First, ensure any orphaned rounds are cleaned up (if any exist)
DELETE FROM rounds WHERE project_id NOT IN (SELECT id FROM projects);

-- Add the foreign key constraint
ALTER TABLE rounds 
ADD CONSTRAINT rounds_project_id_fkey 
FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

-- Also add foreign key for projects -> customers if it doesn't exist
-- First check if the constraint already exists by trying to add it
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'projects_customer_id_fkey'
    ) THEN
        ALTER TABLE projects 
        ADD CONSTRAINT projects_customer_id_fkey 
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT;
    END IF;
END $$;