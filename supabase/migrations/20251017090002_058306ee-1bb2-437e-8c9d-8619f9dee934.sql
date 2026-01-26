-- Add Formula Library to Admin navigation group
DO $$
DECLARE
  v_admin_group_id UUID;
  v_config_id UUID;
BEGIN
  -- Get the active navigation config
  SELECT id INTO v_config_id 
  FROM navigation_config 
  WHERE is_active = true 
  LIMIT 1;

  -- Get the Admin group ID
  SELECT id INTO v_admin_group_id
  FROM navigation_groups
  WHERE config_id = v_config_id
    AND label = 'Admin'
  LIMIT 1;

  -- Only insert if we found the Admin group
  IF v_admin_group_id IS NOT NULL THEN
    -- Insert Formula Library menu item
    INSERT INTO navigation_items (
      group_id,
      label,
      url,
      icon,
      display_order,
      is_visible,
      is_protected,
      required_roles
    )
    VALUES (
      v_admin_group_id,
      'Formula Library',
      '/admin/formula-library',
      'Calculator',
      (SELECT COALESCE(MAX(display_order), 0) + 10 FROM navigation_items WHERE group_id = v_admin_group_id),
      true,
      true,
      ARRAY['admin']::text[]
    )
    ON CONFLICT DO NOTHING;
  END IF;
END $$;