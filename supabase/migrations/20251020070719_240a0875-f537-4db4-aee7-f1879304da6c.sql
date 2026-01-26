-- Step 1: Remove all library references from model exempt positions
UPDATE exempt_positions 
SET library_source_id = NULL 
WHERE library_source_id IS NOT NULL;

-- Step 2: Delete all existing exempt positions from the library
DELETE FROM library_exempt_positions;