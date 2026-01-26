-- Add missing columns to nonexempt_positions for volume driver sync
ALTER TABLE nonexempt_positions
  ADD COLUMN IF NOT EXISTS driver_id UUID REFERENCES volumes(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS driver_ratio NUMERIC DEFAULT 1,
  ADD COLUMN IF NOT EXISTS auto_calculate_hours BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS upph NUMERIC;

-- Add missing columns to exempt_positions for volume driver sync
ALTER TABLE exempt_positions
  ADD COLUMN IF NOT EXISTS driver_id UUID REFERENCES volumes(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS driver_ratio NUMERIC DEFAULT 1,
  ADD COLUMN IF NOT EXISTS auto_calculate_fte BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS upph NUMERIC;

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_nonexempt_positions_driver 
  ON nonexempt_positions(driver_id) 
  WHERE driver_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_exempt_positions_driver 
  ON exempt_positions(driver_id) 
  WHERE driver_id IS NOT NULL;

-- Add comments for documentation
COMMENT ON COLUMN nonexempt_positions.driver_id IS 'Links to volume stream that drives this position''s hours calculation';
COMMENT ON COLUMN nonexempt_positions.driver_ratio IS 'Multiplier applied to volume before calculating hours (default 1)';
COMMENT ON COLUMN nonexempt_positions.auto_calculate_hours IS 'When true, hours are automatically calculated from linked volume driver';
COMMENT ON COLUMN nonexempt_positions.upph IS 'Units Per Person Hour - productivity rate for calculating hours from volume';

COMMENT ON COLUMN exempt_positions.driver_id IS 'Links to volume stream that drives this position''s FTE calculation';
COMMENT ON COLUMN exempt_positions.driver_ratio IS 'Multiplier applied to volume before calculating FTE (default 1)';
COMMENT ON COLUMN exempt_positions.auto_calculate_fte IS 'When true, FTE is automatically calculated from linked volume driver';
COMMENT ON COLUMN exempt_positions.upph IS 'Units Per Person Hour - productivity rate for calculating FTE from volume';