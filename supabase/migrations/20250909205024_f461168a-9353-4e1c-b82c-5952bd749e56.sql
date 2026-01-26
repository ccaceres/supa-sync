-- Add policy to allow admins to insert MFA settings for any user
CREATE POLICY "Admins can create MFA settings for any user" 
ON public.user_mfa_settings 
FOR INSERT 
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));