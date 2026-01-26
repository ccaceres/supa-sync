-- Migration: Add pricing formulas to zulu_standard template
-- Purpose: Enable formula-based rate calculations for price lines

-- 1. Cost Per Unit (CPU) - Foundation calculation
INSERT INTO formula_templates (
  template_name,
  formula_key,
  display_name,
  description,
  expression,
  category,
  result_type,
  result_unit,
  decimal_places,
  depends_on,
  version
) VALUES (
  'zulu_standard',
  'cost_per_unit',
  'Cost Per Unit (CPU)',
  'Calculate cost per unit from total cost and volume. Returns 0 if volume is 0 to prevent division by zero.',
  'volume > 0 ? cost / volume : 0',
  'pricing',
  'currency',
  '$/unit',
  2,
  ARRAY[]::text[],
  1
);

-- 2. Rate from Margin % (RFM) - For margin-based pricing
INSERT INTO formula_templates (
  template_name,
  formula_key,
  display_name,
  description,
  expression,
  category,
  result_type,
  result_unit,
  decimal_places,
  depends_on,
  version
) VALUES (
  'zulu_standard',
  'rate_from_margin',
  'Rate from Margin % (RFM)',
  'Calculate selling rate from cost per unit and target margin percentage. Formula: Rate = Cost / (1 - Margin%). Used when margin_type = "Percentage".',
  'costPerUnit / (1 - marginPercent / 100)',
  'pricing',
  'currency',
  '$/unit',
  2,
  ARRAY['cost_per_unit']::text[],
  1
);

-- 3. Rate from Markup % (RFU) - For markup-based pricing
INSERT INTO formula_templates (
  template_name,
  formula_key,
  display_name,
  description,
  expression,
  category,
  result_type,
  result_unit,
  decimal_places,
  depends_on,
  version
) VALUES (
  'zulu_standard',
  'rate_from_markup',
  'Rate from Markup % (RFU)',
  'Calculate selling rate from cost per unit and markup percentage. Formula: Rate = Cost × (1 + Markup%). Used when margin_type = "Markup".',
  'costPerUnit * (1 + marginPercent / 100)',
  'pricing',
  'currency',
  '$/unit',
  2,
  ARRAY['cost_per_unit']::text[],
  1
);

-- 4. Revenue Calculation (REV) - For P&L projections
INSERT INTO formula_templates (
  template_name,
  formula_key,
  display_name,
  description,
  expression,
  category,
  result_type,
  result_unit,
  decimal_places,
  depends_on,
  version
) VALUES (
  'zulu_standard',
  'revenue_calculation',
  'Revenue (REV)',
  'Calculate revenue from volume and rate. Formula: Revenue = Volume × Rate. Used for P&L reporting and financial projections.',
  'volume * rate',
  'pricing',
  'currency',
  '$',
  0,
  ARRAY[]::text[],
  1
);

-- 5. Actual Margin % Verification (AMP) - Quality check
INSERT INTO formula_templates (
  template_name,
  formula_key,
  display_name,
  description,
  expression,
  category,
  result_type,
  result_unit,
  decimal_places,
  depends_on,
  version
) VALUES (
  'zulu_standard',
  'margin_percent_check',
  'Actual Margin % (AMP)',
  'Verify actual margin percentage achieved from rate and cost. Formula: Margin = (Rate - Cost) / Rate × 100. Returns 0 if rate is 0. Used to validate pricing calculations.',
  'rate > 0 ? ((rate - costPerUnit) / rate) * 100 : 0',
  'pricing',
  'percentage',
  '%',
  2,
  ARRAY['cost_per_unit']::text[],
  1
);