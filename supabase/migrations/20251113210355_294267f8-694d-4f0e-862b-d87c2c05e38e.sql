-- Cleanup: Remove Orphaned Cost Allocations
-- This removes cost_price_allocations records that reference non-existent cost items
-- Safe operation - these allocations already contribute $0 to calculations

-- Delete orphaned OPEX allocations (cost_item_id not in opex_lines)
DELETE FROM cost_price_allocations
WHERE cost_type = 'opex'
  AND NOT EXISTS (
    SELECT 1 FROM opex_lines 
    WHERE opex_lines.id = cost_price_allocations.cost_item_id
  );

-- Delete orphaned CAPEX allocations (cost_item_id not in capex_lines)
DELETE FROM cost_price_allocations
WHERE cost_type = 'capex'
  AND NOT EXISTS (
    SELECT 1 FROM capex_lines 
    WHERE capex_lines.id = cost_price_allocations.cost_item_id
  );

-- Delete orphaned IMPEX allocations (cost_item_id not in impex_lines)
DELETE FROM cost_price_allocations
WHERE cost_type = 'impex'
  AND NOT EXISTS (
    SELECT 1 FROM impex_lines 
    WHERE impex_lines.id = cost_price_allocations.cost_item_id
  );