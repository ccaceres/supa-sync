-- Add recovery configuration columns to impex_lines table
ALTER TABLE public.impex_lines
ADD COLUMN IF NOT EXISTS percent_charged_to_customer DECIMAL(5,2) DEFAULT 100.00 CHECK (percent_charged_to_customer >= 0 AND percent_charged_to_customer <= 100),
ADD COLUMN IF NOT EXISTS recovery_method TEXT DEFAULT 'amortized' CHECK (recovery_method IN ('amortized', 'upfront')),
ADD COLUMN IF NOT EXISTS first_year_of_recovery INTEGER DEFAULT 1 CHECK (first_year_of_recovery >= 1 AND first_year_of_recovery <= 10),
ADD COLUMN IF NOT EXISTS num_amortization_months INTEGER DEFAULT 12 CHECK (num_amortization_months >= 1 AND num_amortization_months <= 120),
ADD COLUMN IF NOT EXISTS annual_amortization_rate DECIMAL(5,2) DEFAULT 0.00 CHECK (annual_amortization_rate >= 0),
ADD COLUMN IF NOT EXISTS upfront_markup DECIMAL(5,2) DEFAULT 0.00 CHECK (upfront_markup >= 0);

COMMENT ON COLUMN public.impex_lines.percent_charged_to_customer IS 'Percentage of cost charged to customer (0-100)';
COMMENT ON COLUMN public.impex_lines.recovery_method IS 'How cost is recovered: amortized or upfront';
COMMENT ON COLUMN public.impex_lines.first_year_of_recovery IS 'Year when recovery begins (1-10)';
COMMENT ON COLUMN public.impex_lines.num_amortization_months IS 'Number of months to amortize over';
COMMENT ON COLUMN public.impex_lines.annual_amortization_rate IS 'Annual rate for amortization calculations';
COMMENT ON COLUMN public.impex_lines.upfront_markup IS 'Markup percentage for upfront recovery';