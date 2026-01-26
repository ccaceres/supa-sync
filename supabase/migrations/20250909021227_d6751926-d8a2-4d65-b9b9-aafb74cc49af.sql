-- Remove the multiple foreign key constraints and use a more flexible approach
-- Drop the constraints we just added (they likely failed anyway)
ALTER TABLE impex_lines DROP CONSTRAINT IF EXISTS fk_impex_lines_volumes_driver;
ALTER TABLE impex_lines DROP CONSTRAINT IF EXISTS fk_impex_lines_salary_roles_driver;
ALTER TABLE impex_lines DROP CONSTRAINT IF EXISTS fk_impex_lines_direct_roles_driver;

-- Add a column to specify the driver type
ALTER TABLE impex_lines ADD COLUMN IF NOT EXISTS driver_type VARCHAR(20);

-- Update existing data to set driver_type based on existing driver_id values
UPDATE impex_lines 
SET driver_type = CASE
  WHEN driver_id IN (SELECT id FROM volumes) THEN 'volume'
  WHEN driver_id IN (SELECT id FROM salary_roles) THEN 'salary_role'  
  WHEN driver_id IN (SELECT id FROM direct_roles) THEN 'direct_role'
  ELSE NULL
END
WHERE driver_id IS NOT NULL;

-- Create individual foreign key constraints based on driver_type
-- Note: We'll handle the relationship validation in the application code
-- since PostgreSQL doesn't natively support conditional foreign keys

-- Add a check constraint to ensure driver_type is valid when driver_id is set
ALTER TABLE impex_lines 
ADD CONSTRAINT chk_impex_driver_type 
CHECK (
  (driver_id IS NULL AND driver_type IS NULL) OR
  (driver_id IS NOT NULL AND driver_type IN ('volume', 'salary_role', 'direct_role'))
);