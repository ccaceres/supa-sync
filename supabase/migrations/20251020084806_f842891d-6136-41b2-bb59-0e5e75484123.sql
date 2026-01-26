-- Add DEFAULT auth.uid() to created_by columns in library tables
-- This ensures created_by always has a value for upsert operations

ALTER TABLE library_exempt_positions 
ALTER COLUMN created_by SET DEFAULT auth.uid();

ALTER TABLE library_nonexempt_positions 
ALTER COLUMN created_by SET DEFAULT auth.uid();

ALTER TABLE library_schedules 
ALTER COLUMN created_by SET DEFAULT auth.uid();

ALTER TABLE library_equipment 
ALTER COLUMN created_by SET DEFAULT auth.uid();