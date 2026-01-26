-- Add manual override flag to price_lines table
-- This flag prevents auto-recalculation from overwriting manually edited rates
ALTER TABLE public.price_lines 
ADD COLUMN IF NOT EXISTS is_manual_override boolean NOT NULL DEFAULT false;

-- Add comment for documentation
COMMENT ON COLUMN public.price_lines.is_manual_override IS 'When true, prevents CAPEX/IMPEX recovery recalculation from overwriting manually edited rates';