-- Drop the broken policy that uses profiles.role
DROP POLICY IF EXISTS "Admins can view all verification attempts" ON ip_verification_attempts;

-- Create new policy using the has_role function which checks user_roles table
CREATE POLICY "Admins can view all verification attempts"
ON ip_verification_attempts
FOR SELECT
TO public
USING (public.has_role(auth.uid(), 'admin'::app_role));