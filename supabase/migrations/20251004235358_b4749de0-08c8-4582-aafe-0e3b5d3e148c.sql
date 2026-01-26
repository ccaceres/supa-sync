-- Create geographic data sync tracking table
CREATE TABLE IF NOT EXISTS geographic_data_syncs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  started_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  status varchar NOT NULL DEFAULT 'in_progress',
  countries_synced integer DEFAULT 0,
  cities_synced integer DEFAULT 0,
  error_message text,
  initiated_by uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now()
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_cities_country_code ON cities(country_code);
CREATE INDEX IF NOT EXISTS idx_cities_state ON cities(state);
CREATE INDEX IF NOT EXISTS idx_countries_code ON countries(code);
CREATE INDEX IF NOT EXISTS idx_geographic_syncs_status ON geographic_data_syncs(status);
CREATE INDEX IF NOT EXISTS idx_geographic_syncs_started ON geographic_data_syncs(started_at DESC);

-- RLS policies for geographic_data_syncs
ALTER TABLE geographic_data_syncs ENABLE ROW LEVEL SECURITY;

-- Admins can view all sync records
CREATE POLICY "Admins can view all sync records"
  ON geographic_data_syncs
  FOR SELECT
  USING (has_role(auth.uid(), 'admin'::app_role));

-- Only admins can create sync records (edge function uses service role)
CREATE POLICY "Service role can manage sync records"
  ON geographic_data_syncs
  FOR ALL
  USING (auth.role() = 'service_role');