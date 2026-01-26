-- Remove market_percentile from unique constraint for library_nonexempt_positions
-- Market percentile is a data field, not part of the business key

-- Drop the existing constraint that incorrectly includes market_percentile
ALTER TABLE library_nonexempt_positions 
DROP CONSTRAINT IF EXISTS library_nonexempt_positions_unique_business_key;

-- Add the correct unique constraint without market_percentile
-- A unique position is defined by: job title, location, year, and currency
ALTER TABLE library_nonexempt_positions 
ADD CONSTRAINT library_nonexempt_positions_unique_business_key 
UNIQUE (job_title_id, country, year, currency, state, city);

-- Create index for performance on the business key
CREATE INDEX IF NOT EXISTS idx_library_nonexempt_positions_business_key 
ON library_nonexempt_positions (job_title_id, country, year, currency, state, city);