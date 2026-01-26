-- Add approval_stage_dates column to rounds table
ALTER TABLE rounds 
ADD COLUMN approval_stage_dates jsonb DEFAULT '{}'::jsonb;

COMMENT ON COLUMN rounds.approval_stage_dates IS 'Stores dates for each approval pipeline stage. Format: {"stage_id": "ISO date string", ...}';