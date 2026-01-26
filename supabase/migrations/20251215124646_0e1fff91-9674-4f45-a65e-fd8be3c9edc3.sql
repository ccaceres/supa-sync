-- Create table for manual cashflow adjustments
CREATE TABLE IF NOT EXISTS public.model_cashflow_adjustments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES public.models(id) ON DELETE CASCADE,
  year INTEGER NOT NULL CHECK (year >= 0 AND year <= 21),
  amount NUMERIC NOT NULL DEFAULT 0,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  created_by UUID REFERENCES auth.users(id),
  CONSTRAINT unique_model_cashflow_year UNIQUE(model_id, year)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_model_cashflow_adjustments_model_id ON public.model_cashflow_adjustments(model_id);

-- Enable RLS
ALTER TABLE public.model_cashflow_adjustments ENABLE ROW LEVEL SECURITY;

-- RLS policies for authenticated users
CREATE POLICY "Users can view cashflow adjustments"
  ON public.model_cashflow_adjustments
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert cashflow adjustments"
  ON public.model_cashflow_adjustments
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update cashflow adjustments"
  ON public.model_cashflow_adjustments
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Users can delete cashflow adjustments"
  ON public.model_cashflow_adjustments
  FOR DELETE
  TO authenticated
  USING (true);

-- Create trigger for updated_at
CREATE TRIGGER update_model_cashflow_adjustments_updated_at
  BEFORE UPDATE ON public.model_cashflow_adjustments
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();