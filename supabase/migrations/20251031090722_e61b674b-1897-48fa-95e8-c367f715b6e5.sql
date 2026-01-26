-- Clear manual quantity overrides from opex_lines table
-- These values will be recalculated from drivers and base_quantity formulas

-- Log the operation for audit purposes
DO $$ 
DECLARE
    affected_rows INTEGER;
BEGIN
    -- Count how many rows have non-null quantity values
    SELECT COUNT(*) INTO affected_rows
    FROM opex_lines
    WHERE quantity_year_1 IS NOT NULL;
    
    RAISE NOTICE 'Clearing manual quantities from % OPEX lines', affected_rows;
END $$;

-- Clear all quantity_year columns
UPDATE public.opex_lines
SET 
  quantity_year_1 = NULL,
  quantity_year_2 = NULL,
  quantity_year_3 = NULL,
  quantity_year_4 = NULL,
  quantity_year_5 = NULL,
  quantity_year_6 = NULL,
  quantity_year_7 = NULL,
  quantity_year_8 = NULL,
  quantity_year_9 = NULL,
  quantity_year_10 = NULL,
  quantity_year_11 = NULL,
  quantity_year_12 = NULL,
  quantity_year_13 = NULL,
  quantity_year_14 = NULL,
  quantity_year_15 = NULL,
  quantity_year_16 = NULL,
  quantity_year_17 = NULL,
  quantity_year_18 = NULL,
  quantity_year_19 = NULL,
  quantity_year_20 = NULL,
  updated_at = NOW();

-- Log completion
DO $$ 
BEGIN
    RAISE NOTICE 'Manual quantities cleared. Users should click "Recalculate All" to repopulate from formulas.';
END $$;