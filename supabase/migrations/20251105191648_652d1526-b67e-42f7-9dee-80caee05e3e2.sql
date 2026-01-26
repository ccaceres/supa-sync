-- Fix RLS policy for cost_price_allocations to include WITH CHECK clause
DROP POLICY IF EXISTS "Users can edit cost allocations for accessible models" 
  ON public.cost_price_allocations;

CREATE POLICY "Users can edit cost allocations for accessible models"
ON public.cost_price_allocations
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.models m
    WHERE m.id = cost_price_allocations.model_id
    AND can_edit_project(auth.uid(), m.project_id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.models m
    WHERE m.id = cost_price_allocations.model_id
    AND can_edit_project(auth.uid(), m.project_id)
  )
);

-- Add unique constraint for upsert operations (safe - won't fail if already exists)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'cost_price_allocations_cost_item_type_unique'
  ) THEN
    ALTER TABLE public.cost_price_allocations
    ADD CONSTRAINT cost_price_allocations_cost_item_type_unique
    UNIQUE (cost_item_id, cost_type);
  END IF;
END $$;