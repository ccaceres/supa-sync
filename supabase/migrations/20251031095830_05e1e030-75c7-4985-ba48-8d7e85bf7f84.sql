-- Add quantity override columns to opex_lines for per-year manual edits
-- Following LABEX Indirect Labor pattern: manual overrides take precedence over formula calculations

ALTER TABLE public.opex_lines
ADD COLUMN IF NOT EXISTS quantity_override_year_1 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_2 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_3 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_4 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_5 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_6 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_7 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_8 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_9 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_10 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_11 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_12 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_13 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_14 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_15 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_16 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_17 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_18 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_19 NUMERIC,
ADD COLUMN IF NOT EXISTS quantity_override_year_20 NUMERIC;

COMMENT ON COLUMN public.opex_lines.quantity_override_year_1 IS 'Manual override for Year 1 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_2 IS 'Manual override for Year 2 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_3 IS 'Manual override for Year 3 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_4 IS 'Manual override for Year 4 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_5 IS 'Manual override for Year 5 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_6 IS 'Manual override for Year 6 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_7 IS 'Manual override for Year 7 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_8 IS 'Manual override for Year 8 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_9 IS 'Manual override for Year 9 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_10 IS 'Manual override for Year 10 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_11 IS 'Manual override for Year 11 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_12 IS 'Manual override for Year 12 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_13 IS 'Manual override for Year 13 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_14 IS 'Manual override for Year 14 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_15 IS 'Manual override for Year 15 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_16 IS 'Manual override for Year 16 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_17 IS 'Manual override for Year 17 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_18 IS 'Manual override for Year 18 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_19 IS 'Manual override for Year 19 quantity (takes precedence over formula calculation)';
COMMENT ON COLUMN public.opex_lines.quantity_override_year_20 IS 'Manual override for Year 20 quantity (takes precedence over formula calculation)';