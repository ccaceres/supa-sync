-- Remove the overly restrictive constraint that prevents multiple allocations per task
ALTER TABLE public.cost_price_allocations
DROP CONSTRAINT IF EXISTS cost_price_allocations_cost_item_type_unique;

-- Add the correct constraint that allows multiple allocations per task
-- but prevents duplicate allocations to the same price line
ALTER TABLE public.cost_price_allocations
ADD CONSTRAINT cost_price_allocations_unique
UNIQUE (cost_item_id, cost_type, price_line_id);

-- Add helpful comment
COMMENT ON CONSTRAINT cost_price_allocations_unique ON public.cost_price_allocations IS 
'Allows one cost item (e.g., LABEX task) to be allocated to multiple price lines, but prevents duplicate allocations to the same price line';