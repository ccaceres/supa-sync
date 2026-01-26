-- Add yearly total cost columns to labex_indirect_labor table
ALTER TABLE labex_indirect_labor 
  ADD COLUMN yearly_total_cost_1 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_2 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_3 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_4 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_5 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_6 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_7 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_8 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_9 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_10 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_11 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_12 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_13 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_14 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_15 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_16 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_17 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_18 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_19 NUMERIC DEFAULT 0,
  ADD COLUMN yearly_total_cost_20 NUMERIC DEFAULT 0;

COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_1 IS 'Total cost for year 1 (base salary + fringe + STI)';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_2 IS 'Total cost for year 2 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_3 IS 'Total cost for year 3 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_4 IS 'Total cost for year 4 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_5 IS 'Total cost for year 5 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_6 IS 'Total cost for year 6 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_7 IS 'Total cost for year 7 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_8 IS 'Total cost for year 8 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_9 IS 'Total cost for year 9 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_10 IS 'Total cost for year 10 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_11 IS 'Total cost for year 11 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_12 IS 'Total cost for year 12 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_13 IS 'Total cost for year 13 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_14 IS 'Total cost for year 14 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_15 IS 'Total cost for year 15 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_16 IS 'Total cost for year 16 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_17 IS 'Total cost for year 17 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_18 IS 'Total cost for year 18 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_19 IS 'Total cost for year 19 with inflation applied';
COMMENT ON COLUMN labex_indirect_labor.yearly_total_cost_20 IS 'Total cost for year 20 with inflation applied';