-- =====================================================
-- Phase 1: CAPEX & IMPEX Recovery System Foundation
-- =====================================================
-- This migration adds:
-- 1. 5 recovery formulas to formula_definitions
-- 2. Calculated columns to capex_lines (3 fields)
-- 3. Calculated columns to impex_lines (2 fields)
-- 4. Performance indexes
-- 5. Documentation comments

-- =====================================================
-- PART 1: Add 5 Recovery Formulas to formula_definitions
-- =====================================================

INSERT INTO formula_definitions (
  model_id,
  formula_key,
  display_name,
  category,
  expression,
  variables,
  result_type,
  description,
  version,
  is_active
) VALUES
-- Formula 1: CAPEX Updated Total Cost (UTC)
(
  NULL,
  'capex_updated_total_cost',
  'CAPEX Updated Total Cost (UTC)',
  'capex',
  'TotalCost / ((1 + CostOfCapital) ^ (FirstYearOfRecovery - PurchaseYear + 1))',
  jsonb_build_array(
    jsonb_build_object('key', 'TotalCost', 'source', 'calculated', 'description', 'Quantity × Unit Cost'),
    jsonb_build_object('key', 'CostOfCapital', 'source', 'parameters.cost_of_capital', 'transform', '/ 100', 'description', 'Cost of capital (decimal)'),
    jsonb_build_object('key', 'FirstYearOfRecovery', 'source', 'capex.first_year_of_recovery', 'description', 'Year to start recovery'),
    jsonb_build_object('key', 'PurchaseYear', 'source', 'capex.investment_year', 'description', 'Year of CAPEX purchase')
  ),
  'currency',
  'Calculates present value of CAPEX at first year of recovery using time value of money. Adjusts total cost by cost of capital over the delay period.',
  1,
  true
),

-- Formula 2: CAPEX Monthly Amortized Recovery (MAR)
(
  NULL,
  'capex_monthly_amortized_recovery',
  'CAPEX Monthly Amortized Recovery (MAR)',
  'capex',
  'PMT(AnnualAmortizationRate / 12, NumAmortizationMonths, UTC * PercentChargedToCustomer)',
  jsonb_build_array(
    jsonb_build_object('key', 'UTC', 'source', 'evaluated', 'depends_on', 'capex_updated_total_cost', 'description', 'Updated Total Cost from time value calculation'),
    jsonb_build_object('key', 'AnnualAmortizationRate', 'source', 'capex.annual_amortization_rate', 'transform', '/ 100', 'description', 'Annual interest rate (decimal)'),
    jsonb_build_object('key', 'NumAmortizationMonths', 'source', 'capex.num_amortization_months', 'description', 'Total months to amortize'),
    jsonb_build_object('key', 'PercentChargedToCustomer', 'source', 'capex.percent_charged_to_customer', 'transform', '/ 100', 'description', 'Percentage of cost to charge (decimal)')
  ),
  'currency',
  'Calculates monthly payment to recover CAPEX investment over the amortization period using the PMT function. Only applies when recovery_method = "amortized".',
  1,
  true
),

-- Formula 3: CAPEX Upfront Recovery
(
  NULL,
  'capex_upfront_recovery',
  'CAPEX Upfront Recovery',
  'capex',
  '(UTC * PercentChargedToCustomer) * (1 + UpfrontMarkup)',
  jsonb_build_array(
    jsonb_build_object('key', 'UTC', 'source', 'evaluated', 'depends_on', 'capex_updated_total_cost', 'description', 'Updated Total Cost from time value calculation'),
    jsonb_build_object('key', 'PercentChargedToCustomer', 'source', 'capex.percent_charged_to_customer', 'transform', '/ 100', 'description', 'Percentage of cost to charge (decimal)'),
    jsonb_build_object('key', 'UpfrontMarkup', 'source', 'capex.upfront_markup', 'transform', '/ 100', 'description', 'Markup percentage (decimal)')
  ),
  'currency',
  'Calculates one-time upfront recovery charge with markup. Only applies when recovery_method = "upfront".',
  1,
  true
),

-- Formula 4: IMPEX Monthly Amortized Recovery (MAR)
(
  NULL,
  'impex_monthly_amortized_recovery',
  'IMPEX Monthly Amortized Recovery (MAR)',
  'impex',
  'PMT(AnnualAmortizationRate / 12, NumAmortizationMonths, IMPEXTotalCost * PercentChargedToCustomer)',
  jsonb_build_array(
    jsonb_build_object('key', 'IMPEXTotalCost', 'source', 'calculated', 'description', 'Quantity × Unit Cost (no time value adjustment for IMPEX)'),
    jsonb_build_object('key', 'AnnualAmortizationRate', 'source', 'impex.annual_amortization_rate', 'transform', '/ 100', 'description', 'Annual interest rate (decimal)'),
    jsonb_build_object('key', 'NumAmortizationMonths', 'source', 'impex.num_amortization_months', 'description', 'Total months to amortize'),
    jsonb_build_object('key', 'PercentChargedToCustomer', 'source', 'impex.percent_charged_to_customer', 'transform', '/ 100', 'description', 'Percentage of cost to charge (decimal)')
  ),
  'currency',
  'Calculates monthly payment to recover IMPEX cost over the amortization period. IMPEX does not use UTC time value adjustment. Only applies when recovery_method = "amortized".',
  1,
  true
),

-- Formula 5: IMPEX Upfront Recovery
(
  NULL,
  'impex_upfront_recovery',
  'IMPEX Upfront Recovery',
  'impex',
  '(IMPEXTotalCost * PercentChargedToCustomer) * (1 + UpfrontMarkup)',
  jsonb_build_array(
    jsonb_build_object('key', 'IMPEXTotalCost', 'source', 'calculated', 'description', 'Quantity × Unit Cost'),
    jsonb_build_object('key', 'PercentChargedToCustomer', 'source', 'impex.percent_charged_to_customer', 'transform', '/ 100', 'description', 'Percentage of cost to charge (decimal)'),
    jsonb_build_object('key', 'UpfrontMarkup', 'source', 'impex.upfront_markup', 'transform', '/ 100', 'description', 'Markup percentage (decimal)')
  ),
  'currency',
  'Calculates one-time upfront recovery charge for IMPEX with markup. Only applies when recovery_method = "upfront".',
  1,
  true
);

-- =====================================================
-- PART 2: Add Calculated Columns to capex_lines
-- =====================================================

ALTER TABLE capex_lines 
ADD COLUMN IF NOT EXISTS updated_total_cost NUMERIC(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS monthly_amortized_recovery NUMERIC(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS upfront_recovery NUMERIC(15,2) DEFAULT 0;

-- =====================================================
-- PART 3: Add Calculated Columns to impex_lines
-- =====================================================

ALTER TABLE impex_lines 
ADD COLUMN IF NOT EXISTS monthly_amortized_recovery NUMERIC(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS upfront_recovery NUMERIC(15,2) DEFAULT 0;

-- =====================================================
-- PART 4: Create Performance Indexes
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_capex_recovery_method ON capex_lines(recovery_method);
CREATE INDEX IF NOT EXISTS idx_capex_investment_year ON capex_lines(investment_year);
CREATE INDEX IF NOT EXISTS idx_impex_recovery_method ON impex_lines(recovery_method);

-- =====================================================
-- PART 5: Add Documentation Comments
-- =====================================================

-- CAPEX calculated columns
COMMENT ON COLUMN capex_lines.updated_total_cost IS 'Present value of CAPEX at first year of recovery (UTC calculation using cost of capital). Formula: TotalCost / ((1 + CoC) ^ (FYOR - PY + 1))';
COMMENT ON COLUMN capex_lines.monthly_amortized_recovery IS 'Monthly payment amount for amortized recovery method (calculated using PMT function). Formula: PMT(AAR/12, NAM, UTC × %CtC)';
COMMENT ON COLUMN capex_lines.upfront_recovery IS 'One-time upfront recovery charge with markup (used when recovery_method = upfront). Formula: (UTC × %CtC) × (1 + Markup)';

-- IMPEX calculated columns
COMMENT ON COLUMN impex_lines.monthly_amortized_recovery IS 'Monthly payment amount for amortized recovery method (calculated using PMT function). Formula: PMT(AAR/12, NAM, TotalCost × %CtC)';
COMMENT ON COLUMN impex_lines.upfront_recovery IS 'One-time upfront recovery charge with markup (used when recovery_method = upfront). Formula: (TotalCost × %CtC) × (1 + Markup)';

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- Run these queries manually after migration to verify installation

-- Verify formulas were created
-- Expected: 5 rows
-- SELECT formula_key, display_name, category, version 
-- FROM formula_definitions 
-- WHERE category IN ('capex', 'impex')
-- ORDER BY formula_key;

-- Verify CAPEX calculated columns
-- Expected: 3 rows (updated_total_cost, monthly_amortized_recovery, upfront_recovery)
-- SELECT column_name, data_type, column_default 
-- FROM information_schema.columns 
-- WHERE table_name = 'capex_lines' 
-- AND column_name IN ('updated_total_cost', 'monthly_amortized_recovery', 'upfront_recovery');

-- Verify IMPEX calculated columns
-- Expected: 2 rows (monthly_amortized_recovery, upfront_recovery)
-- SELECT column_name, data_type, column_default 
-- FROM information_schema.columns 
-- WHERE table_name = 'impex_lines' 
-- AND column_name IN ('monthly_amortized_recovery', 'upfront_recovery');

-- Verify indexes were created
-- Expected: 3 rows
-- SELECT indexname, tablename 
-- FROM pg_indexes 
-- WHERE tablename IN ('capex_lines', 'impex_lines') 
-- AND indexname LIKE 'idx_%recovery%';

-- Verify column comments
-- Expected: 5 rows with descriptions
-- SELECT 
--   table_name,
--   column_name,
--   col_description((table_schema||'.'||table_name)::regclass::oid, ordinal_position) as column_comment
-- FROM information_schema.columns
-- WHERE table_name IN ('capex_lines', 'impex_lines')
-- AND column_name IN ('updated_total_cost', 'monthly_amortized_recovery', 'upfront_recovery')
-- ORDER BY table_name, column_name;