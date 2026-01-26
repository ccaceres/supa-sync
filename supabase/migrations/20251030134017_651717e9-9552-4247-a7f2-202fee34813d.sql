-- Add investment year columns to capex_lines table
ALTER TABLE capex_lines
ADD COLUMN IF NOT EXISTS investment_year_1 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_2 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_3 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_4 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_5 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_6 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_7 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_8 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_9 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_10 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_11 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_12 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_13 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_14 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_15 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_16 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_17 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_18 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_19 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS investment_year_20 numeric DEFAULT 0;

-- Set initial values based on investment_year for existing records
-- This populates the investment in the correct year based on the investment_year field
UPDATE capex_lines
SET 
  investment_year_1 = CASE WHEN investment_year = 0 THEN total_investment ELSE 0 END,
  investment_year_2 = CASE WHEN investment_year = 1 THEN total_investment ELSE 0 END,
  investment_year_3 = CASE WHEN investment_year = 2 THEN total_investment ELSE 0 END,
  investment_year_4 = CASE WHEN investment_year = 3 THEN total_investment ELSE 0 END,
  investment_year_5 = CASE WHEN investment_year = 4 THEN total_investment ELSE 0 END,
  investment_year_6 = CASE WHEN investment_year = 5 THEN total_investment ELSE 0 END,
  investment_year_7 = CASE WHEN investment_year = 6 THEN total_investment ELSE 0 END,
  investment_year_8 = CASE WHEN investment_year = 7 THEN total_investment ELSE 0 END,
  investment_year_9 = CASE WHEN investment_year = 8 THEN total_investment ELSE 0 END,
  investment_year_10 = CASE WHEN investment_year = 9 THEN total_investment ELSE 0 END,
  investment_year_11 = CASE WHEN investment_year = 10 THEN total_investment ELSE 0 END,
  investment_year_12 = CASE WHEN investment_year = 11 THEN total_investment ELSE 0 END,
  investment_year_13 = CASE WHEN investment_year = 12 THEN total_investment ELSE 0 END,
  investment_year_14 = CASE WHEN investment_year = 13 THEN total_investment ELSE 0 END,
  investment_year_15 = CASE WHEN investment_year = 14 THEN total_investment ELSE 0 END,
  investment_year_16 = CASE WHEN investment_year = 15 THEN total_investment ELSE 0 END,
  investment_year_17 = CASE WHEN investment_year = 16 THEN total_investment ELSE 0 END,
  investment_year_18 = CASE WHEN investment_year = 17 THEN total_investment ELSE 0 END,
  investment_year_19 = CASE WHEN investment_year = 18 THEN total_investment ELSE 0 END,
  investment_year_20 = CASE WHEN investment_year = 19 THEN total_investment ELSE 0 END
WHERE total_investment IS NOT NULL;