-- Create a function to bootstrap the first admin user
CREATE OR REPLACE FUNCTION public.bootstrap_first_admin()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  first_user_id uuid;
BEGIN
  -- Get the first user from auth.users (likely you)
  SELECT id INTO first_user_id
  FROM auth.users
  ORDER BY created_at ASC
  LIMIT 1;
  
  -- Assign admin role
  INSERT INTO public.user_roles (user_id, role, assigned_by, is_active)
  VALUES (
    first_user_id,
    'admin'::app_role,
    first_user_id,
    true
  )
  ON CONFLICT (user_id, role) DO UPDATE
  SET is_active = true;
  
  RETURN first_user_id;
END;
$$;

-- Don't execute immediately - no users exist during migration
-- Call public.bootstrap_first_admin() after first user is created
-- SELECT public.bootstrap_first_admin();