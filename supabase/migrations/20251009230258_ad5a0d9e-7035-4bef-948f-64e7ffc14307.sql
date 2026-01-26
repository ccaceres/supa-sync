-- Phase 1: Create price_lines table
CREATE TABLE IF NOT EXISTS public.price_lines (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  model_id UUID NOT NULL REFERENCES models(id) ON DELETE CASCADE,
  volume_stream_id UUID NOT NULL,
  line_name VARCHAR NOT NULL,
  pl_category VARCHAR NOT NULL,
  margin_markup_percent NUMERIC,
  margin_type VARCHAR DEFAULT 'Percentage',
  
  -- Rates for 20 years
  rate_1 NUMERIC DEFAULT 0,
  rate_2 NUMERIC DEFAULT 0,
  rate_3 NUMERIC DEFAULT 0,
  rate_4 NUMERIC DEFAULT 0,
  rate_5 NUMERIC DEFAULT 0,
  rate_6 NUMERIC DEFAULT 0,
  rate_7 NUMERIC DEFAULT 0,
  rate_8 NUMERIC DEFAULT 0,
  rate_9 NUMERIC DEFAULT 0,
  rate_10 NUMERIC DEFAULT 0,
  rate_11 NUMERIC DEFAULT 0,
  rate_12 NUMERIC DEFAULT 0,
  rate_13 NUMERIC DEFAULT 0,
  rate_14 NUMERIC DEFAULT 0,
  rate_15 NUMERIC DEFAULT 0,
  rate_16 NUMERIC DEFAULT 0,
  rate_17 NUMERIC DEFAULT 0,
  rate_18 NUMERIC DEFAULT 0,
  rate_19 NUMERIC DEFAULT 0,
  rate_20 NUMERIC DEFAULT 0,
  
  row_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Add foreign key for volume_stream_id
ALTER TABLE public.price_lines
ADD CONSTRAINT fk_price_lines_volume_stream
FOREIGN KEY (volume_stream_id) REFERENCES volumes(id) ON DELETE CASCADE;

-- Enable RLS
ALTER TABLE public.price_lines ENABLE ROW LEVEL SECURITY;

-- RLS policies for price_lines (matching volumes pattern)
CREATE POLICY "Users can view price lines for accessible models"
ON public.price_lines FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = price_lines.model_id
    AND can_access_project(auth.uid(), m.project_id)
  )
);

CREATE POLICY "Users can edit price lines for accessible models"
ON public.price_lines FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = price_lines.model_id
    AND can_edit_project(auth.uid(), m.project_id)
  )
);

-- Phase 2: Extend volumes table to 20 years
ALTER TABLE public.volumes
ADD COLUMN IF NOT EXISTS year_11 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS year_12 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS year_13 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS year_14 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS year_15 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS year_16 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS year_17 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS year_18 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS year_19 NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS year_20 NUMERIC DEFAULT 0;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_price_lines_model_id ON public.price_lines(model_id);
CREATE INDEX IF NOT EXISTS idx_price_lines_volume_stream_id ON public.price_lines(volume_stream_id);

-- Add trigger for updated_at
CREATE TRIGGER update_price_lines_updated_at
  BEFORE UPDATE ON public.price_lines
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();