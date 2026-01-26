-- Add enhanced progress tracking columns to geographic_data_syncs
ALTER TABLE geographic_data_syncs
ADD COLUMN current_country_name text,
ADD COLUMN current_country_index integer DEFAULT 0,
ADD COLUMN rate_limit_hits integer DEFAULT 0,
ADD COLUMN last_activity_at timestamp with time zone DEFAULT now(),
ADD COLUMN estimated_completion_at timestamp with time zone;