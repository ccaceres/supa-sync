-- Create function to get active users with emails (admin only)
CREATE OR REPLACE FUNCTION get_active_users_with_emails()
RETURNS TABLE (
  id uuid,
  email text,
  full_name text,
  status varchar
) 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Check if user is admin
  IF NOT EXISTS (
    SELECT 1 FROM user_roles 
    WHERE user_id = auth.uid() 
    AND role = 'admin' 
    AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Only administrators can access user list';
  END IF;

  -- Return active users with emails
  RETURN QUERY
  SELECT 
    p.user_id as id,
    u.email::text,
    p.full_name,
    p.status
  FROM profiles p
  INNER JOIN auth.users u ON u.id = p.user_id
  WHERE p.status = 'active'
  ORDER BY p.full_name ASC NULLS LAST;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_active_users_with_emails() TO authenticated;