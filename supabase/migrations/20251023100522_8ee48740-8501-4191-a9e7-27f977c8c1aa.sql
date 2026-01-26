-- Clean up city and state values in library_nonexempt_positions
-- Convert period characters and empty strings to null for consistency

UPDATE library_nonexempt_positions 
SET city = NULL 
WHERE city = '.' OR city = '';

UPDATE library_nonexempt_positions 
SET state = NULL 
WHERE state = '.' OR state = '';

-- Also clean up library_exempt_positions for consistency
UPDATE library_exempt_positions 
SET city = NULL 
WHERE city = '.' OR city = '';

UPDATE library_exempt_positions 
SET state = NULL 
WHERE state = '.' OR state = '';