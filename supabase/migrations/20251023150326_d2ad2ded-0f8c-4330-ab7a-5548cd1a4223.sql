-- Phase 2: Add Total Operating HC and Total Payroll HC columns to dl_roles
-- These columns store the sum of HC across all shifts (Shift 1 + Shift 2 + Shift 3)

-- Add Total Operating HC columns (20 years)
ALTER TABLE public.dl_roles
ADD COLUMN IF NOT EXISTS total_operating_hc_year_1 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_2 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_3 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_4 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_5 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_6 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_7 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_8 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_9 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_10 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_11 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_12 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_13 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_14 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_15 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_16 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_17 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_18 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_19 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_operating_hc_year_20 numeric DEFAULT 0;

-- Add Total Payroll HC columns (20 years)
ALTER TABLE public.dl_roles
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_1 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_2 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_3 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_4 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_5 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_6 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_7 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_8 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_9 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_10 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_11 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_12 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_13 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_14 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_15 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_16 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_17 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_18 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_19 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_payroll_hc_year_20 numeric DEFAULT 0;

COMMENT ON COLUMN public.dl_roles.total_operating_hc_year_1 IS 'Sum of operating HC across all shifts (S1 + S2 + S3) for Year 1';
COMMENT ON COLUMN public.dl_roles.total_payroll_hc_year_1 IS 'Sum of payroll HC across all shifts (S1 + S2 + S3) for Year 1';