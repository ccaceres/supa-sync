-- Create function to automatically assign roles from invitations
CREATE OR REPLACE FUNCTION public.handle_invitation_signup()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    invitation_record RECORD;
BEGIN
    -- Check if there's a pending invitation for this user's email
    SELECT * INTO invitation_record
    FROM public.user_invitations
    WHERE email = NEW.raw_user_meta_data->>'email'
    AND accepted_at IS NOT NULL
    AND expires_at > NOW()
    LIMIT 1;
    
    -- If invitation exists, assign the role
    IF invitation_record.id IS NOT NULL THEN
        INSERT INTO public.user_roles (user_id, role, assigned_by)
        VALUES (NEW.id, invitation_record.role, invitation_record.invited_by);
    END IF;
    
    RETURN NEW;
END;
$$;

-- Create trigger for invitation-based role assignment
CREATE TRIGGER on_auth_user_invited_signup
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_invitation_signup();