-- Add Shift 2 Operating HC columns (Years 1-20)
ALTER TABLE public.dl_roles
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_1 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_2 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_3 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_4 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_5 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_6 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_7 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_8 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_9 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_10 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_11 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_12 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_13 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_14 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_15 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_16 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_17 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_18 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_19 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_operating_hc_year_20 numeric DEFAULT 0;

-- Add Shift 3 Operating HC columns (Years 1-20)
ALTER TABLE public.dl_roles
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_1 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_2 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_3 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_4 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_5 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_6 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_7 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_8 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_9 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_10 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_11 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_12 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_13 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_14 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_15 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_16 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_17 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_18 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_19 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_operating_hc_year_20 numeric DEFAULT 0;

-- Add Shift 2 Payroll HC columns (Years 1-20)
ALTER TABLE public.dl_roles
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_1 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_2 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_3 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_4 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_5 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_6 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_7 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_8 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_9 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_10 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_11 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_12 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_13 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_14 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_15 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_16 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_17 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_18 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_19 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_2_payroll_hc_year_20 numeric DEFAULT 0;

-- Add Shift 3 Payroll HC columns (Years 1-20)
ALTER TABLE public.dl_roles
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_1 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_2 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_3 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_4 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_5 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_6 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_7 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_8 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_9 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_10 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_11 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_12 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_13 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_14 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_15 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_16 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_17 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_18 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_19 numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS shift_3_payroll_hc_year_20 numeric DEFAULT 0;

-- Add comments
COMMENT ON COLUMN public.dl_roles.shift_2_operating_hc_year_1 IS 'Shift 2 Operating HC calculated by Formula Engine for Year 1';
COMMENT ON COLUMN public.dl_roles.shift_3_operating_hc_year_1 IS 'Shift 3 Operating HC calculated by Formula Engine for Year 1';
COMMENT ON COLUMN public.dl_roles.shift_2_payroll_hc_year_1 IS 'Shift 2 Payroll HC calculated by Formula Engine for Year 1';
COMMENT ON COLUMN public.dl_roles.shift_3_payroll_hc_year_1 IS 'Shift 3 Payroll HC calculated by Formula Engine for Year 1';