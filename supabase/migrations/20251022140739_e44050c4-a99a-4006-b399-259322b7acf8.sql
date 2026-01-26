-- Add yearly total cost columns to dl_roles table for pricing calculations
ALTER TABLE dl_roles
ADD COLUMN IF NOT EXISTS yearly_total_cost_1 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_2 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_3 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_4 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_5 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_6 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_7 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_8 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_9 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_10 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_11 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_12 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_13 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_14 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_15 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_16 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_17 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_18 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_19 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_total_cost_20 NUMERIC DEFAULT 0;

-- Add comment explaining the purpose
COMMENT ON COLUMN dl_roles.yearly_total_cost_1 IS 'Total LABEX cost for year 1 (labor + attrition), calculated from formulas';
COMMENT ON COLUMN dl_roles.yearly_total_cost_20 IS 'Total LABEX cost for year 20 (labor + attrition), calculated from formulas';