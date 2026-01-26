-- Phase 1: Enforce Round Dependency

-- First, create default rounds for projects that don't have any rounds
INSERT INTO rounds (project_id, name, round_number, status, description, created_by)
SELECT 
    p.id as project_id,
    'Round 1' as name,
    1 as round_number,
    'Active' as status,
    'Default round created during migration' as description,
    p.created_by
FROM projects p
LEFT JOIN rounds r ON p.id = r.project_id
WHERE r.id IS NULL;

-- Update orphaned models to be associated with the first round of their project
UPDATE models 
SET round_id = (
    SELECT r.id 
    FROM rounds r 
    WHERE r.project_id = models.project_id 
    ORDER BY r.round_number ASC 
    LIMIT 1
)
WHERE round_id IS NULL;

-- Add NOT NULL constraint to models.round_id to enforce round dependency
ALTER TABLE models 
ALTER COLUMN round_id SET NOT NULL;

-- Add foreign key constraint if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'models_round_id_fkey' 
        AND table_name = 'models'
    ) THEN
        ALTER TABLE models 
        ADD CONSTRAINT models_round_id_fkey 
        FOREIGN KEY (round_id) REFERENCES rounds(id) ON DELETE CASCADE;
    END IF;
END $$;