-- Create table for spreadsheet view preferences
CREATE TABLE public.spreadsheet_view_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  model_id UUID NOT NULL,
  view_type VARCHAR(50) NOT NULL,
  
  -- View settings
  grouping_mode VARCHAR(20) DEFAULT 'none',
  expanded_rows JSONB DEFAULT '[]'::jsonb,
  freeze_panes BOOLEAN DEFAULT true,
  zoom INTEGER DEFAULT 100,
  number_format VARCHAR(20) DEFAULT 'number',
  decimal_places INTEGER DEFAULT 0,
  
  -- Row colors
  row_colors JSONB DEFAULT '{}'::jsonb,
  
  -- Filter & sort
  active_filters JSONB DEFAULT '{}'::jsonb,
  sort_config JSONB DEFAULT '{}'::jsonb,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, model_id, view_type)
);

-- Index for fast lookups
CREATE INDEX idx_spreadsheet_prefs_user_model 
ON public.spreadsheet_view_preferences(user_id, model_id, view_type);

-- RLS policies
ALTER TABLE public.spreadsheet_view_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own spreadsheet preferences"
ON public.spreadsheet_view_preferences
FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Trigger to update updated_at
CREATE TRIGGER update_spreadsheet_prefs_updated_at
  BEFORE UPDATE ON public.spreadsheet_view_preferences
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();