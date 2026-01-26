-- Phase 1: Admin Impersonation Sessions Audit Trail
-- Table to track all impersonation sessions for security and compliance

CREATE TABLE IF NOT EXISTS public.admin_impersonation_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  impersonated_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reason TEXT,
  started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  ended_at TIMESTAMPTZ,
  session_duration_minutes INTEGER DEFAULT 30,
  ip_address INET,
  user_agent TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for performance
CREATE INDEX idx_impersonation_admin ON public.admin_impersonation_sessions(admin_user_id, started_at DESC);
CREATE INDEX idx_impersonation_target ON public.admin_impersonation_sessions(impersonated_user_id);
CREATE INDEX idx_impersonation_active ON public.admin_impersonation_sessions(is_active) WHERE is_active = true;

-- Enable RLS
ALTER TABLE public.admin_impersonation_sessions ENABLE ROW LEVEL SECURITY;

-- Only admins can view impersonation logs
CREATE POLICY "Admins can view impersonation logs"
ON public.admin_impersonation_sessions
FOR SELECT
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role));

-- Only admins can create impersonation sessions
CREATE POLICY "Admins can create impersonation sessions"
ON public.admin_impersonation_sessions
FOR INSERT
TO authenticated
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Only admins can end impersonation sessions
CREATE POLICY "Admins can end impersonation sessions"
ON public.admin_impersonation_sessions
FOR UPDATE
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role));