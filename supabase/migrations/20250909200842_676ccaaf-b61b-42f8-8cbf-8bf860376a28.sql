-- Create MFA settings and audit tables for enhanced security management

-- Table to track user MFA preferences and settings
CREATE TABLE public.user_mfa_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    totp_enabled BOOLEAN DEFAULT FALSE,
    sms_enabled BOOLEAN DEFAULT FALSE,
    webauthn_enabled BOOLEAN DEFAULT FALSE,
    backup_codes_generated BOOLEAN DEFAULT FALSE,
    microsoft_linked BOOLEAN DEFAULT FALSE,
    force_mfa_enabled BOOLEAN DEFAULT FALSE,
    mfa_setup_completed_at TIMESTAMP WITH TIME ZONE,
    last_mfa_verification TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Table to track MFA admin actions for audit purposes
CREATE TABLE public.mfa_admin_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    admin_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    action VARCHAR(50) NOT NULL, -- 'force_enable', 'disable', 'reset', 'view_status'
    reason TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table to store role-based MFA requirements
CREATE TABLE public.role_mfa_requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role app_role NOT NULL,
    mfa_required BOOLEAN DEFAULT FALSE,
    grace_period_days INTEGER DEFAULT 7,
    enforcement_level VARCHAR(20) DEFAULT 'optional', -- 'required', 'recommended', 'optional'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(role)
);

-- Enable RLS on all tables
ALTER TABLE public.user_mfa_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mfa_admin_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_mfa_requirements ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_mfa_settings
CREATE POLICY "Users can view their own MFA settings"
    ON public.user_mfa_settings FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own MFA settings"
    ON public.user_mfa_settings FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own MFA settings"
    ON public.user_mfa_settings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all MFA settings"
    ON public.user_mfa_settings FOR SELECT
    USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update MFA settings"
    ON public.user_mfa_settings FOR UPDATE
    USING (has_role(auth.uid(), 'admin'));

-- RLS Policies for mfa_admin_actions
CREATE POLICY "Admins can manage MFA admin actions"
    ON public.mfa_admin_actions FOR ALL
    USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Users can view admin actions on their account"
    ON public.mfa_admin_actions FOR SELECT
    USING (auth.uid() = target_user_id);

-- RLS Policies for role_mfa_requirements
CREATE POLICY "Anyone can view role MFA requirements"
    ON public.role_mfa_requirements FOR SELECT
    USING (true);

CREATE POLICY "Admins can manage role MFA requirements"
    ON public.role_mfa_requirements FOR ALL
    USING (has_role(auth.uid(), 'admin'));

-- Insert default role MFA requirements
INSERT INTO public.role_mfa_requirements (role, mfa_required, grace_period_days, enforcement_level) VALUES
    ('admin', true, 1, 'required'),
    ('manager', true, 7, 'required'),
    ('analyst', false, 14, 'recommended'),
    ('viewer', false, 30, 'optional');

-- Function to automatically create MFA settings when user is created
CREATE OR REPLACE FUNCTION public.handle_new_user_mfa()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_mfa_settings (user_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Trigger to create MFA settings for new users
CREATE TRIGGER on_auth_user_created_mfa
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_mfa();

-- Function to check if user needs MFA based on roles
CREATE OR REPLACE FUNCTION public.user_requires_mfa(user_uuid UUID)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 
        FROM public.user_roles ur
        JOIN public.role_mfa_requirements rmr ON ur.role = rmr.role
        WHERE ur.user_id = user_uuid 
        AND ur.is_active = true
        AND rmr.mfa_required = true
    )
$$;

-- Function to log MFA admin actions
CREATE OR REPLACE FUNCTION public.log_mfa_admin_action(
    target_user UUID,
    action_type VARCHAR(50),
    reason_text TEXT DEFAULT NULL,
    action_metadata JSONB DEFAULT '{}'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    action_id UUID;
BEGIN
    INSERT INTO public.mfa_admin_actions (
        target_user_id, 
        admin_user_id, 
        action, 
        reason, 
        metadata
    ) VALUES (
        target_user, 
        auth.uid(), 
        action_type, 
        reason_text, 
        action_metadata
    ) RETURNING id INTO action_id;
    
    RETURN action_id;
END;
$$;