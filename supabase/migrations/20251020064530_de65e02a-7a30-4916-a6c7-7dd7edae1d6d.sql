-- Delete all existing nonexempt positions from the library
-- This clears the table to resolve job_title_id NULL issues
DELETE FROM library_nonexempt_positions;