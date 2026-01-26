-- Clear the stuck sync job
UPDATE geographic_data_syncs 
SET status = 'error',
    error_message = 'Manual reset - implementing pause/stop controls',
    completed_at = NOW()
WHERE id = 'f1e8b3e1-3735-477b-984f-7973b4926a6e';

-- Add columns to track pause/cancel actions
ALTER TABLE geographic_data_syncs 
ADD COLUMN IF NOT EXISTS paused_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS paused_by UUID REFERENCES auth.users(id),
ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS cancelled_by UUID REFERENCES auth.users(id);