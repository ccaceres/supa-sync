-- Phase 1: Restructure Salary Roles Tables (Safe Migration)
-- Add new columns to library_salary_roles
ALTER TABLE library_salary_roles 
  ADD COLUMN IF NOT EXISTS position_name VARCHAR,
  ADD COLUMN IF NOT EXISTS project VARCHAR,
  ADD COLUMN IF NOT EXISTS year INTEGER DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER,
  ADD COLUMN IF NOT EXISTS market_percentile NUMERIC,
  ADD COLUMN IF NOT EXISTS base_per_year NUMERIC DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fringe_percentage NUMERIC,
  ADD COLUMN IF NOT EXISTS sti_percentage NUMERIC,
  ADD COLUMN IF NOT EXISTS sti_fringe_percentage NUMERIC,
  ADD COLUMN IF NOT EXISTS hiring_cost NUMERIC,
  ADD COLUMN IF NOT EXISTS annual_attrition_rate NUMERIC;

-- Safe data migration for library_salary_roles
DO $$
BEGIN
  -- Copy role_name to position_name if it exists
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'library_salary_roles' AND column_name = 'role_name') THEN
    UPDATE library_salary_roles SET position_name = role_name WHERE position_name IS NULL;
  END IF;
  
  -- Copy annual_salary to base_per_year if it exists
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'library_salary_roles' AND column_name = 'annual_salary') THEN
    UPDATE library_salary_roles SET base_per_year = annual_salary WHERE base_per_year = 0 OR base_per_year IS NULL;
  END IF;
END $$;

-- Set default for position_name if null
UPDATE library_salary_roles SET position_name = 'Unnamed Position' WHERE position_name IS NULL;
UPDATE library_salary_roles SET year = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER WHERE year IS NULL;

-- Make required columns NOT NULL
ALTER TABLE library_salary_roles
  ALTER COLUMN position_name SET NOT NULL,
  ALTER COLUMN year SET NOT NULL,
  ALTER COLUMN base_per_year SET NOT NULL;

-- Drop old columns if they exist
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'library_salary_roles' AND column_name = 'role_name') THEN
    ALTER TABLE library_salary_roles DROP COLUMN role_name;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'library_salary_roles' AND column_name = 'role_code') THEN
    ALTER TABLE library_salary_roles DROP COLUMN role_code;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'library_salary_roles' AND column_name = 'role_category') THEN
    ALTER TABLE library_salary_roles DROP COLUMN role_category;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'library_salary_roles' AND column_name = 'annual_salary') THEN
    ALTER TABLE library_salary_roles DROP COLUMN annual_salary;
  END IF;
END $$;

-- Same for salary_roles table
ALTER TABLE salary_roles 
  ADD COLUMN IF NOT EXISTS position_name VARCHAR,
  ADD COLUMN IF NOT EXISTS project VARCHAR,
  ADD COLUMN IF NOT EXISTS year INTEGER DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER,
  ADD COLUMN IF NOT EXISTS market_percentile NUMERIC,
  ADD COLUMN IF NOT EXISTS base_per_year NUMERIC DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fringe_percentage NUMERIC,
  ADD COLUMN IF NOT EXISTS sti_percentage NUMERIC,
  ADD COLUMN IF NOT EXISTS sti_fringe_percentage NUMERIC,
  ADD COLUMN IF NOT EXISTS hiring_cost NUMERIC,
  ADD COLUMN IF NOT EXISTS annual_attrition_rate NUMERIC;

-- Safe data migration for salary_roles
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'salary_roles' AND column_name = 'role_name') THEN
    UPDATE salary_roles SET position_name = role_name WHERE position_name IS NULL;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'salary_roles' AND column_name = 'annual_salary') THEN
    UPDATE salary_roles SET base_per_year = annual_salary WHERE base_per_year = 0 OR base_per_year IS NULL;
  END IF;
END $$;

UPDATE salary_roles SET position_name = 'Unnamed Position' WHERE position_name IS NULL;
UPDATE salary_roles SET year = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER WHERE year IS NULL;

ALTER TABLE salary_roles
  ALTER COLUMN position_name SET NOT NULL,
  ALTER COLUMN year SET NOT NULL,
  ALTER COLUMN base_per_year SET NOT NULL;

-- Drop old columns if they exist
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'salary_roles' AND column_name = 'role_name') THEN
    ALTER TABLE salary_roles DROP COLUMN role_name;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'salary_roles' AND column_name = 'role_code') THEN
    ALTER TABLE salary_roles DROP COLUMN role_code;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'salary_roles' AND column_name = 'role_category') THEN
    ALTER TABLE salary_roles DROP COLUMN role_category;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'salary_roles' AND column_name = 'annual_salary') THEN
    ALTER TABLE salary_roles DROP COLUMN annual_salary;
  END IF;
END $$;