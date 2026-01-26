-- Create page_alerts_config table for dynamic alert management
CREATE TABLE IF NOT EXISTS public.page_alerts_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  route_pattern TEXT NOT NULL,
  alert_id TEXT NOT NULL,
  alert_type TEXT NOT NULL CHECK (alert_type IN ('info', 'warning', 'error', 'success')),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  dismissible BOOLEAN NOT NULL DEFAULT true,
  priority INTEGER NOT NULL DEFAULT 0,
  action_label TEXT,
  action_url_template TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(route_pattern, alert_id)
);

-- Enable RLS
ALTER TABLE public.page_alerts_config ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to view active alerts
CREATE POLICY "Authenticated users can view active alert configs"
  ON public.page_alerts_config
  FOR SELECT
  TO authenticated
  USING (is_active = true);

-- Admins can manage alert configs
CREATE POLICY "Admins can manage alert configs"
  ON public.page_alerts_config
  FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Create index for faster route lookups
CREATE INDEX idx_page_alerts_route_pattern ON public.page_alerts_config(route_pattern) WHERE is_active = true;

-- Seed initial equipment page alerts
INSERT INTO public.page_alerts_config (route_pattern, alert_id, alert_type, title, message, dismissible, priority, display_order)
VALUES 
  (
    '/projects/{projectId}/rounds/{roundId}/models/{modelId}/equipment',
    'equipment-factors-info',
    'info',
    'Equipment Factors & Impositions',
    'Equipment factors are now managed per task in LABEX. Navigate to LABEX to configure equipment sets and factors.',
    false,
    1,
    1
  ),
  (
    '/projects/{projectId}/rounds/{roundId}/models/{modelId}/equipment',
    'cost-flow-info',
    'info',
    'Cost Flow Information',
    'Lease Equipment → OPEX | Purchase Equipment → CAPEX (purchase cost) | Purchase Maintenance → OPEX. Edit costs in Equipment Library, quantities are calculated by formulas here.',
    false,
    1,
    2
  )
ON CONFLICT (route_pattern, alert_id) DO NOTHING;