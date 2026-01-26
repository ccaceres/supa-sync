-- Add FTE columns to dl_roles table for Full-Time Equivalent tracking
-- Aligns with labex_indirect_labor schema which already has these columns

ALTER TABLE dl_roles
  ADD COLUMN IF NOT EXISTS fte_year_1 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_2 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_3 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_4 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_5 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_6 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_7 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_8 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_9 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_10 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_11 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_12 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_13 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_14 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_15 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_16 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_17 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_18 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_19 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fte_year_20 numeric DEFAULT 0;

-- Backfill existing data where total_operating_hc exists but fte is 0
-- This ensures existing calculated tasks have FTE values populated
UPDATE dl_roles
SET 
  fte_year_1 = COALESCE(total_operating_hc_year_1, 0),
  fte_year_2 = COALESCE(total_operating_hc_year_2, 0),
  fte_year_3 = COALESCE(total_operating_hc_year_3, 0),
  fte_year_4 = COALESCE(total_operating_hc_year_4, 0),
  fte_year_5 = COALESCE(total_operating_hc_year_5, 0),
  fte_year_6 = COALESCE(total_operating_hc_year_6, 0),
  fte_year_7 = COALESCE(total_operating_hc_year_7, 0),
  fte_year_8 = COALESCE(total_operating_hc_year_8, 0),
  fte_year_9 = COALESCE(total_operating_hc_year_9, 0),
  fte_year_10 = COALESCE(total_operating_hc_year_10, 0),
  fte_year_11 = COALESCE(total_operating_hc_year_11, 0),
  fte_year_12 = COALESCE(total_operating_hc_year_12, 0),
  fte_year_13 = COALESCE(total_operating_hc_year_13, 0),
  fte_year_14 = COALESCE(total_operating_hc_year_14, 0),
  fte_year_15 = COALESCE(total_operating_hc_year_15, 0),
  fte_year_16 = COALESCE(total_operating_hc_year_16, 0),
  fte_year_17 = COALESCE(total_operating_hc_year_17, 0),
  fte_year_18 = COALESCE(total_operating_hc_year_18, 0),
  fte_year_19 = COALESCE(total_operating_hc_year_19, 0),
  fte_year_20 = COALESCE(total_operating_hc_year_20, 0)
WHERE 
  (fte_year_1 IS NULL OR fte_year_1 = 0)
  AND total_operating_hc_year_1 IS NOT NULL
  AND total_operating_hc_year_1 > 0;

-- Add helpful comment
COMMENT ON COLUMN dl_roles.fte_year_1 IS 'Full-Time Equivalent positions calculated from total_operating_hc formula';