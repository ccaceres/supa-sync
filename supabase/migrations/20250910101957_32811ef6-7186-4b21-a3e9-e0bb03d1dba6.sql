-- Add user status and last login tracking to profiles table
ALTER TABLE public.profiles 
ADD COLUMN status character varying DEFAULT 'active'::character varying,
ADD COLUMN last_login_at timestamp with time zone,
ADD COLUMN deactivated_at timestamp with time zone,
ADD COLUMN deactivated_by uuid REFERENCES auth.users(id);

-- Create function to deactivate user (sets status to inactive and removes active roles)
CREATE OR REPLACE FUNCTION public.deactivate_user(target_user_id uuid, reason text DEFAULT NULL)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    -- Check if user is admin
    IF NOT has_role(auth.uid(), 'admin'::app_role) THEN
        RAISE EXCEPTION 'Only admins can deactivate users';
    END IF;
    
    -- Update profile status
    UPDATE public.profiles 
    SET 
        status = 'inactive',
        deactivated_at = NOW(),
        deactivated_by = auth.uid(),
        updated_at = NOW()
    WHERE user_id = target_user_id;
    
    -- Deactivate all user roles
    UPDATE public.user_roles 
    SET is_active = false
    WHERE user_id = target_user_id AND is_active = true;
    
    RETURN FOUND;
END;
$$;

-- Create function to reactivate user
CREATE OR REPLACE FUNCTION public.reactivate_user(target_user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    -- Check if user is admin
    IF NOT has_role(auth.uid(), 'admin'::app_role) THEN
        RAISE EXCEPTION 'Only admins can reactivate users';
    END IF;
    
    -- Update profile status
    UPDATE public.profiles 
    SET 
        status = 'active',
        deactivated_at = NULL,
        deactivated_by = NULL,
        updated_at = NOW()
    WHERE user_id = target_user_id;
    
    RETURN FOUND;
END;
$$;

-- Update last_login_at when user signs in (trigger on auth.users)
CREATE OR REPLACE FUNCTION public.update_last_login()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    UPDATE public.profiles
    SET last_login_at = NOW()
    WHERE user_id = NEW.id;
    RETURN NEW;
END;
$$;

-- Create trigger for last login tracking
DROP TRIGGER IF EXISTS on_auth_user_login ON auth.users;
CREATE TRIGGER on_auth_user_login
    AFTER UPDATE ON auth.users
    FOR EACH ROW
    WHEN (OLD.last_sign_in_at IS DISTINCT FROM NEW.last_sign_in_at)
    EXECUTE FUNCTION public.update_last_login();