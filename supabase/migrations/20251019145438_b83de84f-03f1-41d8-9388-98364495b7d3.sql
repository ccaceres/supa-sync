-- Assign admin role to the current user to grant library permissions
DO $$
DECLARE
  v_user_id uuid;
BEGIN
  -- Get the current user's ID (first user created)
  SELECT id INTO v_user_id
  FROM auth.users
  ORDER BY created_at ASC
  LIMIT 1;

  -- Only insert if user exists
  IF v_user_id IS NOT NULL THEN
    INSERT INTO public.user_roles (user_id, role, assigned_by, is_active)
    VALUES (
      v_user_id,
      'admin'::app_role,
      v_user_id,
      true
    )
    ON CONFLICT (user_id, role) DO UPDATE
    SET is_active = true;

    RAISE NOTICE 'Admin role assigned to user %', v_user_id;
  ELSE
    RAISE NOTICE 'No users exist yet, skipping admin role assignment';
  END IF;
END $$;
