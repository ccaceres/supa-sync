-- Add unique constraint for job_title_id + country
-- This prevents duplicate job titles within the same country
ALTER TABLE library_nonexempt_positions 
ADD CONSTRAINT library_nonexempt_positions_job_title_country_unique 
UNIQUE (job_title_id, country);

-- Also apply same rule to nonexempt_positions table for consistency
ALTER TABLE nonexempt_positions 
ADD CONSTRAINT nonexempt_positions_job_title_country_unique 
UNIQUE (job_title_id, country, model_id);