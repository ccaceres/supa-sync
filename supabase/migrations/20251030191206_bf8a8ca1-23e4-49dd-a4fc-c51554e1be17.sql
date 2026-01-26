-- Drop the overly restrictive job_title_id + country constraint
-- This constraint prevents having the same job title in different states/percentiles
ALTER TABLE library_nonexempt_positions 
DROP CONSTRAINT IF EXISTS library_nonexempt_positions_job_title_country_unique;

ALTER TABLE nonexempt_positions 
DROP CONSTRAINT IF EXISTS nonexempt_positions_job_title_country_unique;

-- Drop the old business key constraint that doesn't include market_percentile
ALTER TABLE library_nonexempt_positions 
DROP CONSTRAINT IF EXISTS library_nonexempt_positions_unique_business_key;

-- Add the CORRECT unique constraint:
-- job_title_id + country + state + market_percentile
-- This allows same job title in different states or different percentiles
ALTER TABLE library_nonexempt_positions 
ADD CONSTRAINT library_nonexempt_positions_unique_position 
UNIQUE (job_title_id, country, state, market_percentile);

-- Same for model-level positions (including model_id to scope uniqueness per model)
ALTER TABLE nonexempt_positions 
ADD CONSTRAINT nonexempt_positions_unique_position 
UNIQUE (job_title_id, country, state, market_percentile, model_id);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_library_nonexempt_positions_lookup 
ON library_nonexempt_positions (job_title_id, country, state, market_percentile);

CREATE INDEX IF NOT EXISTS idx_nonexempt_positions_lookup 
ON nonexempt_positions (job_title_id, country, state, market_percentile, model_id);