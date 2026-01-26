-- Clean slate: Delete demo data
TRUNCATE projects CASCADE;
TRUNCATE rounds CASCADE;

-- Create project category enum
CREATE TYPE project_category AS ENUM (
  'New Business',
  'Existing Business', 
  'Consultative'
);

-- Create project type enum with all subcategories
CREATE TYPE project_type AS ENUM (
  'RFP Response',
  'Non-Competitive',
  'Incremental Scope',
  'Renewal',
  'Reprice',
  'Network Design',
  'ROM',
  'CI/Implementation Assistance'
);

-- Create round type enum
CREATE TYPE round_type AS ENUM (
  'Competitive Round',
  'Partnership Round',
  'Scope Extension Round',
  'Rate Adjustment Round',
  'Advisory Round',
  'Standard Round'
);

-- Add category column to projects table
ALTER TABLE projects ADD COLUMN category project_category;

-- Drop the old type column and recreate it with the new enum
ALTER TABLE projects DROP COLUMN type;
ALTER TABLE projects ADD COLUMN type project_type NOT NULL DEFAULT 'Non-Competitive';

-- Add type column to rounds table
ALTER TABLE rounds ADD COLUMN type round_type DEFAULT 'Standard Round';

-- Add comments for documentation
COMMENT ON COLUMN projects.category IS 'Main business category: New Business, Existing Business, or Consultative';
COMMENT ON COLUMN projects.type IS 'Specific project type within the category';
COMMENT ON COLUMN rounds.type IS 'Type of round aligned with project workflow';