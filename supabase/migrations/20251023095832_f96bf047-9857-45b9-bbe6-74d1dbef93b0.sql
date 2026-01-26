-- Add unique constraint to library_nonexempt_positions to enforce business rules
-- This prevents duplicate positions with the same job title, location, year, and market data

-- First, remove any existing duplicates by keeping only the most recent version
DELETE FROM library_nonexempt_positions a
USING library_nonexempt_positions b
WHERE a.id < b.id
  AND a.job_title_id = b.job_title_id
  AND a.country = b.country
  AND a.year = b.year
  AND a.currency = b.currency
  AND COALESCE(a.state, '') = COALESCE(b.state, '')
  AND COALESCE(a.city, '') = COALESCE(b.city, '')
  AND COALESCE(a.market_percentile, 0) = COALESCE(b.market_percentile, 0);

-- Add the unique constraint
ALTER TABLE library_nonexempt_positions
ADD CONSTRAINT library_nonexempt_positions_unique_business_key 
UNIQUE (job_title_id, country, year, currency, state, city, market_percentile);

-- Create an index to improve lookup performance
CREATE INDEX IF NOT EXISTS idx_library_nonexempt_positions_lookup 
ON library_nonexempt_positions (job_title_id, country, year, currency);