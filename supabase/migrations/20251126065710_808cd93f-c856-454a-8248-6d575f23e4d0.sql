-- Fix cost_price_allocations constraint to prevent multiple price lines per cost item
-- 
-- ISSUE: Previous constraint UNIQUE (cost_item_id, cost_type, price_line_id) only prevented
-- assigning the same price line twice, but allowed multiple different price lines per cost item.
-- This caused the "Price Line Imposition" display bug where old allocations were still visible.
--
-- SOLUTION: Change to UNIQUE (cost_item_id, cost_type) to enforce one allocation per cost item.
-- This ensures each OPEX/CAPEX/IMPEX line can only be assigned to ONE price line at a time.
--
-- USER IMPACT: None - the app already prevents duplicates by deleting old allocations first.
-- This constraint is an additional safeguard at the database level.

-- Drop the old constraint
ALTER TABLE cost_price_allocations 
DROP CONSTRAINT IF EXISTS cost_price_allocations_unique;

-- Add the correct constraint: one allocation per (cost_item_id, cost_type)
ALTER TABLE cost_price_allocations 
ADD CONSTRAINT cost_price_allocations_one_per_item 
UNIQUE (cost_item_id, cost_type);

-- Add helpful comment
COMMENT ON CONSTRAINT cost_price_allocations_one_per_item ON cost_price_allocations 
IS 'Enforces that each cost item (OPEX/CAPEX/IMPEX) can only be assigned to one price line at a time. Prevents duplicate allocations that cause display bugs.';
