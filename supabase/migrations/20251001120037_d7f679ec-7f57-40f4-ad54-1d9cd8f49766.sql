-- Grant admin role to the current user (carlos) so they can manage pipeline stages
INSERT INTO public.user_roles (user_id, role, assigned_by, is_active)
VALUES (
  '43d473ce-8e9c-481b-8614-b96c439361c0',
  'admin'::app_role,
  '43d473ce-8e9c-481b-8614-b96c439361c0',
  true
)
ON CONFLICT (user_id, role) 
DO UPDATE SET 
  is_active = true,
  assigned_at = NOW();