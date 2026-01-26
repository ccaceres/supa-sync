-- Drop the default first to avoid dependency issues
ALTER TABLE rounds ALTER COLUMN status DROP DEFAULT;

-- Change the column to text temporarily
ALTER TABLE rounds ALTER COLUMN status TYPE text;

-- Drop the old enum
DROP TYPE IF EXISTS round_status;

-- Create new enum with updated values
CREATE TYPE round_status AS ENUM ('Active', 'On Hold', 'Cancel', 'Approved');

-- Update existing data to new status values
UPDATE rounds SET status = 'On Hold' WHERE status = 'Planning';
UPDATE rounds SET status = 'On Hold' WHERE status = 'Review';
UPDATE rounds SET status = 'Approved' WHERE status = 'Completed';
UPDATE rounds SET status = 'Cancel' WHERE status = 'Cancelled';

-- Convert the column back to the enum type
ALTER TABLE rounds ALTER COLUMN status TYPE round_status USING status::round_status;

-- Set default to 'Active'
ALTER TABLE rounds ALTER COLUMN status SET DEFAULT 'Active'::round_status;