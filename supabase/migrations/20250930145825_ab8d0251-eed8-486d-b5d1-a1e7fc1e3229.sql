-- Add 'qualification' to the scorecard_category enum
-- Note: This is done safely by creating a new enum and updating the columns

-- First, create a new enum with all values including qualification
CREATE TYPE scorecard_category_new AS ENUM (
  'qualification',
  'solution_go',
  'information_availability',
  'operational_review',
  'financial_review',
  'elt_review'
);

-- Update the round_process_scorecards table to use the new enum
ALTER TABLE round_process_scorecards 
  ALTER COLUMN category TYPE scorecard_category_new 
  USING category::text::scorecard_category_new;

-- Drop the old enum
DROP TYPE IF EXISTS scorecard_category;

-- Rename the new enum to the original name
ALTER TYPE scorecard_category_new RENAME TO scorecard_category;