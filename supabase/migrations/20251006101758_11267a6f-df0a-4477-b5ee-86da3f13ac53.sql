-- Add missing project types to the project_type enum
-- This syncs the database enum with System Settings

ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'Advisory';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'Assessment';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'Scope Expansion';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'Proactive Bid';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'Market Entry';