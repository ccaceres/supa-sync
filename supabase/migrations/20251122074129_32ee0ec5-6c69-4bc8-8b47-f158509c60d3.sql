-- Create ip_verification_attempts table
CREATE TABLE public.ip_verification_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  client_ip VARCHAR(45) NOT NULL,
  verification_token UUID NOT NULL DEFAULT gen_random_uuid(),
  email_sent_at TIMESTAMPTZ,
  verified_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'expired', 'failed')),
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_verification_token ON public.ip_verification_attempts(verification_token);
CREATE INDEX idx_user_ip ON public.ip_verification_attempts(user_id, client_ip);
CREATE INDEX idx_status ON public.ip_verification_attempts(status);

-- Enable RLS
ALTER TABLE public.ip_verification_attempts ENABLE ROW LEVEL SECURITY;

-- Users can view their own verification attempts
CREATE POLICY "Users can view their own verification attempts"
ON public.ip_verification_attempts
FOR SELECT
USING (auth.uid() = user_id);

-- Users can create verification attempts
CREATE POLICY "Users can create verification attempts"
ON public.ip_verification_attempts
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Admins can view all verification attempts
CREATE POLICY "Admins can view all verification attempts"
ON public.ip_verification_attempts
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid()
    AND profiles.role = 'admin'
  )
);

-- Add new system settings for adaptive verification
INSERT INTO public.system_settings (setting_key, setting_value, category, description)
VALUES 
  ('adaptive_ip_verification_enabled', 'false', 'security', 'Enable adaptive IP verification for unrecognized locations'),
  ('auto_whitelist_verified_ips', 'false', 'security', 'Automatically add verified IPs to whitelist'),
  ('verification_token_expiry_minutes', '15', 'security', 'Minutes until verification token expires')
ON CONFLICT (setting_key) DO NOTHING;

-- Create trigger for updated_at
CREATE TRIGGER update_ip_verification_attempts_updated_at
BEFORE UPDATE ON public.ip_verification_attempts
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();