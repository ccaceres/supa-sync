-- Clean up duplicate cost_price_allocations
-- This migration removes older duplicate allocations, keeping only the most recent one per (cost_item_id, cost_type)
-- This fixes the grid display issue where old price lines are shown due to find() returning the first (oldest) match

-- Delete older duplicates, keeping only the most recent allocation per cost item
DELETE FROM cost_price_allocations 
WHERE id IN (
  SELECT id FROM (
    SELECT id, ROW_NUMBER() OVER (
      PARTITION BY cost_item_id, cost_type 
      ORDER BY created_at DESC
    ) as rn
    FROM cost_price_allocations
  ) ranked 
  WHERE rn > 1
);

-- Add comment explaining the cleanup
COMMENT ON TABLE cost_price_allocations IS 'Maps cost items (OPEX/CAPEX/IMPEX) to price lines. Each cost item should have only one active allocation at a time.';
