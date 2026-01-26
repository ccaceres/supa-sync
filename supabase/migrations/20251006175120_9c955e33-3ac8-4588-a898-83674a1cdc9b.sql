-- Phase 1: Create states table to separate state/province data
CREATE TABLE IF NOT EXISTS public.states (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  country_code VARCHAR(3) NOT NULL REFERENCES public.countries(code) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(10),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(country_code, name)
);

CREATE INDEX idx_states_country_code ON public.states(country_code);
CREATE INDEX idx_states_name ON public.states(name);

-- Phase 2: Create geographic sync preferences table
CREATE TABLE IF NOT EXISTS public.geographic_sync_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  selected_countries TEXT[] DEFAULT '{}',
  selected_states JSONB DEFAULT '{}',
  auto_sync_new_countries BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id)
);

-- Phase 3: Update geographic_data_syncs table with phase tracking
ALTER TABLE public.geographic_data_syncs 
ADD COLUMN IF NOT EXISTS sync_phase VARCHAR(20) DEFAULT 'countries',
ADD COLUMN IF NOT EXISTS current_phase_countries TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS phase_1_completed_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS phase_2_completed_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS phase_3_completed_at TIMESTAMPTZ;

-- Phase 4: Migrate existing city data to populate states table
-- Only insert where country exists in countries table
INSERT INTO public.states (country_code, name)
SELECT DISTINCT c.country_code, c.state
FROM public.cities c
WHERE c.state IS NOT NULL
  AND c.state != ''
  AND EXISTS (SELECT 1 FROM public.countries co WHERE co.code = c.country_code)
  AND NOT EXISTS (
    SELECT 1 FROM public.states s
    WHERE s.country_code = c.country_code
    AND s.name = c.state
  );

-- Phase 5: Enable RLS on new tables
ALTER TABLE public.states ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.geographic_sync_preferences ENABLE ROW LEVEL SECURITY;

-- RLS Policies for states
CREATE POLICY "Anyone can view states"
  ON public.states FOR SELECT
  USING (true);

-- RLS Policies for sync preferences
CREATE POLICY "Users can view their own sync preferences"
  ON public.geographic_sync_preferences FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own sync preferences"
  ON public.geographic_sync_preferences FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own sync preferences"
  ON public.geographic_sync_preferences FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage all sync preferences"
  ON public.geographic_sync_preferences FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role));

-- Add trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_geographic_sync_preferences_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_geographic_sync_preferences_timestamp
  BEFORE UPDATE ON public.geographic_sync_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_geographic_sync_preferences_updated_at();