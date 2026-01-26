-- Phase 4: Add FTE columns to nonexempt_positions table
-- This stores Formula Engine calculated FTE values to eliminate hardcoded "hours / 2080" conversions

ALTER TABLE public.nonexempt_positions
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

COMMENT ON COLUMN public.nonexempt_positions.fte_year_1 IS 'FTE calculated by Formula Engine using actual schedule configuration (e.g., 213 days × 7.7 hours = 1,640 hours/year), not hardcoded 2080';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_2 IS 'FTE calculated by Formula Engine for Year 2';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_3 IS 'FTE calculated by Formula Engine for Year 3';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_4 IS 'FTE calculated by Formula Engine for Year 4';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_5 IS 'FTE calculated by Formula Engine for Year 5';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_6 IS 'FTE calculated by Formula Engine for Year 6';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_7 IS 'FTE calculated by Formula Engine for Year 7';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_8 IS 'FTE calculated by Formula Engine for Year 8';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_9 IS 'FTE calculated by Formula Engine for Year 9';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_10 IS 'FTE calculated by Formula Engine for Year 10';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_11 IS 'FTE calculated by Formula Engine for Year 11';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_12 IS 'FTE calculated by Formula Engine for Year 12';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_13 IS 'FTE calculated by Formula Engine for Year 13';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_14 IS 'FTE calculated by Formula Engine for Year 14';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_15 IS 'FTE calculated by Formula Engine for Year 15';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_16 IS 'FTE calculated by Formula Engine for Year 16';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_17 IS 'FTE calculated by Formula Engine for Year 17';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_18 IS 'FTE calculated by Formula Engine for Year 18';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_19 IS 'FTE calculated by Formula Engine for Year 19';
COMMENT ON COLUMN public.nonexempt_positions.fte_year_20 IS 'FTE calculated by Formula Engine for Year 20';