-- Create function to delete all MFA factors for a user (admin only)
-- This function runs with elevated privileges to access the auth schema
CREATE OR REPLACE FUNCTION public.admin_reset_user_mfa(target_user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- First delete all MFA challenges for this user's factors
    DELETE FROM auth.mfa_challenges 
    WHERE factor_id IN (
        SELECT id FROM auth.mfa_factors WHERE user_id = target_user_id
    );
    
    -- Then delete all MFA factors
    WITH deleted AS (
        DELETE FROM auth.mfa_factors 
        WHERE user_id = target_user_id
        RETURNING id
    )
    SELECT COUNT(*) INTO deleted_count FROM deleted;
    
    RETURN deleted_count;
END;
$$;

-- Grant execute permission to authenticated users (will be further restricted by edge function auth checks)
GRANT EXECUTE ON FUNCTION public.admin_reset_user_mfa(UUID) TO authenticated;