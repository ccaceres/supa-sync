-- Add current_phase_states column for Phase 3 (cities) tracking
ALTER TABLE public.geographic_data_syncs 
ADD COLUMN IF NOT EXISTS current_phase_states JSONB DEFAULT '{}';

-- Add index for performance when querying by phase states
CREATE INDEX IF NOT EXISTS idx_geographic_syncs_phase_states 
ON public.geographic_data_syncs USING GIN (current_phase_states);

-- Add comment to document the column purpose
COMMENT ON COLUMN public.geographic_data_syncs.current_phase_states IS 'Stores state mappings for Phase 3 city sync, e.g., {"USA": ["CA", "TX"], "CAN": ["ON", "BC"]}';