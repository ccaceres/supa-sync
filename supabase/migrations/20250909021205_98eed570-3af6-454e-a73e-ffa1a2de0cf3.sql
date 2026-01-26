-- Add foreign key constraints for IMPEX driver relationships
-- These constraints allow PostgREST to perform joins between impex_lines and driver tables

-- Add foreign key constraint to volumes table for driver_id
ALTER TABLE impex_lines 
ADD CONSTRAINT fk_impex_lines_volumes_driver 
FOREIGN KEY (driver_id) 
REFERENCES volumes(id) 
ON DELETE SET NULL;

-- Add foreign key constraint to salary_roles table for driver_id  
ALTER TABLE impex_lines 
ADD CONSTRAINT fk_impex_lines_salary_roles_driver 
FOREIGN KEY (driver_id) 
REFERENCES salary_roles(id) 
ON DELETE SET NULL;

-- Add foreign key constraint to direct_roles table for driver_id
ALTER TABLE impex_lines 
ADD CONSTRAINT fk_impex_lines_direct_roles_driver 
FOREIGN KEY (driver_id) 
REFERENCES direct_roles(id) 
ON DELETE SET NULL;

-- Note: These constraints will allow NULL values since driver_id is optional
-- and multiple constraints on the same column allow the driver_id to reference 
-- any of the three driver types (volumes, salary_roles, or direct_roles)