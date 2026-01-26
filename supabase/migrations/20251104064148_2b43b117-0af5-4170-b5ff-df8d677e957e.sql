-- Add missing year columns to impex_lines table (years 11-20)
-- This makes IMPEX consistent with OPEX and LabEx which have 20 year columns

ALTER TABLE impex_lines
  ADD COLUMN IF NOT EXISTS cost_year_11 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cost_year_12 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cost_year_13 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cost_year_14 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cost_year_15 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cost_year_16 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cost_year_17 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cost_year_18 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cost_year_19 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cost_year_20 numeric DEFAULT 0;

COMMENT ON COLUMN impex_lines.cost_year_11 IS 'Calculated cost for year 11';
COMMENT ON COLUMN impex_lines.cost_year_12 IS 'Calculated cost for year 12';
COMMENT ON COLUMN impex_lines.cost_year_13 IS 'Calculated cost for year 13';
COMMENT ON COLUMN impex_lines.cost_year_14 IS 'Calculated cost for year 14';
COMMENT ON COLUMN impex_lines.cost_year_15 IS 'Calculated cost for year 15';
COMMENT ON COLUMN impex_lines.cost_year_16 IS 'Calculated cost for year 16';
COMMENT ON COLUMN impex_lines.cost_year_17 IS 'Calculated cost for year 17';
COMMENT ON COLUMN impex_lines.cost_year_18 IS 'Calculated cost for year 18';
COMMENT ON COLUMN impex_lines.cost_year_19 IS 'Calculated cost for year 19';
COMMENT ON COLUMN impex_lines.cost_year_20 IS 'Calculated cost for year 20';