-- Clean up duplicate OPEX allocations and add constraint to prevent future duplicates

-- Step 1: Delete specific duplicate allocations for FTZ Admin Fee - Outbound
DELETE FROM cost_price_allocations 
WHERE id IN (
  '9fa33039-c739-4b89-aa5a-68b698a9b86b',  -- FTZ Bond insurance (older duplicate)
  '3c1c2b58-2b97-4f76-8505-ced7b22df000',  -- FTZ Grantee Fee (older duplicate)
  '14d52603-8837-4076-b701-b90bcff255db'   -- FTZ Software License (older duplicate)
);

-- Step 2: Delete duplicate allocations for Fixed Monthly Fee - Warehouse Rent
DELETE FROM cost_price_allocations 
WHERE id IN (
  '63ec1381-96c8-4b46-9e42-6cbba7f931c4',  -- Warehouse Rent (older/higher duplicate)
  '433fbb63-2947-4672-8a35-720ce2d2955f'   -- Warehouse Opex (older/higher duplicate)
);

-- Step 3: Delete orphaned duplicate OPEX items
DELETE FROM opex_lines 
WHERE id IN (
  '5e486448-a0be-47d2-883a-5df4bef7f03b',  -- FTZ Bond insurance duplicate
  'e32999ae-2b45-425c-8606-9884d3c39d4c',  -- FTZ Grantee Fee duplicate
  '4f2fc5e0-ab55-4bd4-9f9d-0fb34d2827b9'   -- FTZ Software License duplicate
);

-- Step 4: Add unique constraint to prevent future duplicates
-- This ensures each cost item can only be allocated once to each price line
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_cost_allocation 
ON cost_price_allocations(price_line_id, cost_type, cost_item_id);