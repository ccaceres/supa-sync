-- Remove duplicate cost allocations (keep only one per cost_item_id + price_line_id + cost_type)
-- This fixes the over-allocation issues caused by duplicate records

WITH duplicates AS (
  SELECT 
    id,
    cost_item_id,
    price_line_id,
    cost_type,
    ROW_NUMBER() OVER (
      PARTITION BY cost_item_id, price_line_id, cost_type 
      ORDER BY created_at ASC, id ASC
    ) as rn
  FROM cost_price_allocations
  WHERE model_id = 'e9988147-9a29-4046-abf6-3feab37f969d'
)
DELETE FROM cost_price_allocations
WHERE id IN (
  SELECT id FROM duplicates WHERE rn > 1
);