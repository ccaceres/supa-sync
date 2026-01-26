-- Add 'impex' to the cost_price_allocations cost_type check constraint
ALTER TABLE public.cost_price_allocations 
  DROP CONSTRAINT IF EXISTS cost_price_allocations_cost_type_check;

ALTER TABLE public.cost_price_allocations 
  ADD CONSTRAINT cost_price_allocations_cost_type_check 
  CHECK (cost_type IN ('labex', 'opex', 'capex', 'impex'));

-- Add comment for clarity
COMMENT ON COLUMN public.cost_price_allocations.cost_type IS 
  'Type of cost item: labex (labor), opex (operating expenses), capex (capital expenses), impex (implementation expenses)';