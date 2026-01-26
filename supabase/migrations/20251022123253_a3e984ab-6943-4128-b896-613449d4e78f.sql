-- Create cost_price_allocations table for flexible cost assignment to price lines
-- This supports both 1:1 and 1:many relationships with percentage allocation

CREATE TABLE IF NOT EXISTS public.cost_price_allocations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  model_id UUID NOT NULL REFERENCES public.models(id) ON DELETE CASCADE,
  cost_type TEXT NOT NULL CHECK (cost_type IN ('labex', 'opex', 'capex')),
  cost_item_id UUID NOT NULL,
  price_line_id UUID NOT NULL REFERENCES public.price_lines(id) ON DELETE CASCADE,
  allocation_percentage DECIMAL(5,2) NOT NULL DEFAULT 100.00 CHECK (allocation_percentage > 0 AND allocation_percentage <= 100),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create indexes for performance
CREATE INDEX idx_cost_price_allocations_model ON public.cost_price_allocations(model_id);
CREATE INDEX idx_cost_price_allocations_price_line ON public.cost_price_allocations(price_line_id);
CREATE INDEX idx_cost_price_allocations_cost_item ON public.cost_price_allocations(cost_item_id, cost_type);

-- Enable RLS
ALTER TABLE public.cost_price_allocations ENABLE ROW LEVEL SECURITY;

-- RLS Policies using existing permission functions
CREATE POLICY "Users can view cost allocations for accessible models"
ON public.cost_price_allocations
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.models m
    WHERE m.id = cost_price_allocations.model_id
    AND can_access_project(auth.uid(), m.project_id)
  )
);

CREATE POLICY "Users can edit cost allocations for accessible models"
ON public.cost_price_allocations
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.models m
    WHERE m.id = cost_price_allocations.model_id
    AND can_edit_project(auth.uid(), m.project_id)
  )
);

-- Add trigger for updated_at
CREATE TRIGGER update_cost_price_allocations_updated_at
BEFORE UPDATE ON public.cost_price_allocations
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Extend OpEx table to 20 years
ALTER TABLE public.opex_lines
ADD COLUMN IF NOT EXISTS cost_year_11 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_12 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_13 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_14 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_15 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_16 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_17 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_18 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_19 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_20 DECIMAL(15,2) DEFAULT 0;

-- Extend CapEx table to 20 years
ALTER TABLE public.capex_lines
ADD COLUMN IF NOT EXISTS cost_year_11 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_12 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_13 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_14 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_15 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_16 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_17 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_18 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_19 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_year_20 DECIMAL(15,2) DEFAULT 0;