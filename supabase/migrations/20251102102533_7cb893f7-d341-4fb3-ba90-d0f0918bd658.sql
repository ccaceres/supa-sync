-- Get the active config ID and insert Tools group
DO $$
DECLARE
  v_config_id uuid;
  v_tools_group_id uuid;
BEGIN
  -- Get active config ID
  SELECT id INTO v_config_id FROM navigation_config WHERE is_active = true LIMIT 1;

  -- Exit early if no config exists (no users yet)
  IF v_config_id IS NULL THEN
    RAISE NOTICE 'No navigation config exists, skipping Tools group creation';
    RETURN;
  END IF;

  -- Update display_order for existing global groups at position 4 and above
  UPDATE navigation_groups
  SET display_order = display_order + 1
  WHERE config_id = v_config_id
  AND display_order >= 4
  AND context_scope = 'global';

  -- Insert Tools group
  INSERT INTO navigation_groups (
    config_id,
    label,
    icon,
    display_order,
    is_visible,
    is_collapsible,
    context_scope
  )
  VALUES (
    v_config_id,
    'Tools',
    'Wrench',
    4,
    true,
    true,
    'model'
  )
  RETURNING id INTO v_tools_group_id;

  -- Insert LABEX Validation item
  INSERT INTO navigation_items (
    group_id,
    label,
    url,
    icon,
    display_order,
    is_visible,
    is_protected,
    url_type,
    context_required,
    required_permissions
  )
  VALUES (
    v_tools_group_id,
    'LABEX Validation',
    '/projects/{projectId}/rounds/{roundId}/models/{modelId}/labex-validation',
    'Users',
    0,
    true,
    false,
    'model',
    true,
    ARRAY['models.view']::text[]
  );

  -- Insert Cost Model Validation item
  INSERT INTO navigation_items (
    group_id,
    label,
    url,
    icon,
    display_order,
    is_visible,
    is_protected,
    url_type,
    context_required,
    required_permissions
  )
  VALUES (
    v_tools_group_id,
    'Cost Model Validation',
    '/projects/{projectId}/rounds/{roundId}/models/{modelId}/cost-validation',
    'CheckCircle2',
    1,
    true,
    false,
    'model',
    true,
    ARRAY['models.view']::text[]
  );
END $$;
