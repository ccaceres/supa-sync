-- Create system settings table
CREATE TABLE public.system_settings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  setting_key VARCHAR NOT NULL UNIQUE,
  setting_value JSONB NOT NULL,
  category VARCHAR NOT NULL,
  description TEXT,
  data_type VARCHAR NOT NULL DEFAULT 'string', -- string, boolean, number, json
  is_public BOOLEAN NOT NULL DEFAULT false, -- if setting can be read by non-admins
  validation_rules JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id)
);

-- Enable RLS
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Admins can manage all system settings"
ON public.system_settings
FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users can read public system settings"
ON public.system_settings
FOR SELECT
TO authenticated
USING (is_public = true);

-- Create trigger for updated_at
CREATE TRIGGER update_system_settings_updated_at
    BEFORE UPDATE ON public.system_settings
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Insert default settings
INSERT INTO public.system_settings (setting_key, setting_value, category, description, data_type, is_public) VALUES
-- User Registration & Authentication
('allow_user_registrations', 'true', 'authentication', 'Allow new users to register accounts', 'boolean', true),
('force_email_verification', 'false', 'authentication', 'Require email verification for new accounts', 'boolean', false),
('default_user_role', '"viewer"', 'authentication', 'Default role assigned to new users', 'string', false),
('password_min_length', '8', 'authentication', 'Minimum password length requirement', 'number', true),

-- MFA Settings  
('mfa_grace_period_days', '7', 'mfa', 'Grace period in days before MFA enforcement', 'number', false),
('mfa_default_enforcement', '"optional"', 'mfa', 'Default MFA enforcement level (required, optional, disabled)', 'string', false),

-- Security & Access
('session_timeout_hours', '24', 'security', 'Session timeout in hours', 'number', false),
('max_login_attempts', '5', 'security', 'Maximum failed login attempts before lockout', 'number', false),
('account_lockout_minutes', '15', 'security', 'Account lockout duration in minutes', 'number', false),

-- System Behavior
('auto_logout_minutes', '480', 'system', 'Auto-logout inactive users after minutes (0 = disabled)', 'number', false),
('audit_log_retention_days', '365', 'system', 'How long to keep audit logs in days', 'number', false),
('backup_enabled', 'false', 'system', 'Enable automated backups', 'boolean', false),

-- Notifications
('email_notifications_enabled', 'true', 'notifications', 'Enable system email notifications', 'boolean', false),
('admin_notification_email', '""', 'notifications', 'Admin email for system notifications', 'string', false);

-- Create function to get setting value
CREATE OR REPLACE FUNCTION public.get_system_setting(p_setting_key VARCHAR)
RETURNS JSONB
LANGUAGE SQL
STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT setting_value 
  FROM public.system_settings 
  WHERE setting_key = p_setting_key
$$;

-- Create function to update setting (admin only)
CREATE OR REPLACE FUNCTION public.update_system_setting(
  p_setting_key VARCHAR,
  p_setting_value JSONB,
  p_updated_by UUID DEFAULT auth.uid()
)
RETURNS BOOLEAN
LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Check if user is admin
  IF NOT has_role(auth.uid(), 'admin'::app_role) THEN
    RAISE EXCEPTION 'Only admins can update system settings';
  END IF;
  
  -- Update the setting
  UPDATE public.system_settings 
  SET 
    setting_value = p_setting_value,
    updated_at = NOW(),
    updated_by = p_updated_by
  WHERE setting_key = p_setting_key;
  
  RETURN FOUND;
END;
$$;