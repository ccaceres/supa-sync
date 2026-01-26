-- Add recovery configuration fields to capex_lines table
ALTER TABLE capex_lines 
ADD COLUMN IF NOT EXISTS percent_charged_to_customer numeric DEFAULT 100,
ADD COLUMN IF NOT EXISTS recovery_method text DEFAULT 'upfront',
ADD COLUMN IF NOT EXISTS first_year_of_recovery integer DEFAULT 1,
ADD COLUMN IF NOT EXISTS num_amortization_months integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS annual_amortization_rate numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS upfront_markup numeric DEFAULT 0;

-- Add check constraint for recovery_method
ALTER TABLE capex_lines 
ADD CONSTRAINT capex_lines_recovery_method_check 
CHECK (recovery_method IN ('upfront', 'amortized'));

-- Add check constraints for valid ranges
ALTER TABLE capex_lines 
ADD CONSTRAINT capex_lines_percent_charged_check 
CHECK (percent_charged_to_customer >= 0 AND percent_charged_to_customer <= 100);

ALTER TABLE capex_lines 
ADD CONSTRAINT capex_lines_first_year_check 
CHECK (first_year_of_recovery >= 1 AND first_year_of_recovery <= 20);

ALTER TABLE capex_lines 
ADD CONSTRAINT capex_lines_amortization_months_check 
CHECK (num_amortization_months >= 0);

ALTER TABLE capex_lines 
ADD CONSTRAINT capex_lines_annual_rate_check 
CHECK (annual_amortization_rate >= 0);

ALTER TABLE capex_lines 
ADD CONSTRAINT capex_lines_upfront_markup_check 
CHECK (upfront_markup >= 0);

COMMENT ON COLUMN capex_lines.percent_charged_to_customer IS 'Percentage of CAPEX cost to be charged to customers (0-100)';
COMMENT ON COLUMN capex_lines.recovery_method IS 'Method for recovering CAPEX: upfront or amortized';
COMMENT ON COLUMN capex_lines.first_year_of_recovery IS 'First year when recovery begins (1-20)';
COMMENT ON COLUMN capex_lines.num_amortization_months IS 'Number of months for amortization (only for amortized method)';
COMMENT ON COLUMN capex_lines.annual_amortization_rate IS 'Annual interest rate for amortization as decimal (e.g., 0.05 for 5%)';
COMMENT ON COLUMN capex_lines.upfront_markup IS 'Markup percentage for upfront recovery as decimal (e.g., 0.15 for 15%)';