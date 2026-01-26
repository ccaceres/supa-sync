-- Add batch processing tracking columns to geographic_data_syncs table
ALTER TABLE geographic_data_syncs 
  ADD COLUMN IF NOT EXISTS last_processed_country_index INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS batch_number INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS states_synced INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS is_resumable BOOLEAN DEFAULT true;

-- Clear the stuck sync job
UPDATE geographic_data_syncs 
SET status = 'error', 
    error_message = 'Timeout - clearing for batch implementation',
    completed_at = NOW()
WHERE status = 'in_progress' AND countries_synced = 0;