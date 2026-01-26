-- Add P&L Analysis to navigation structure
-- This makes P&L visible in the menu builder and model navigation

DO $$
DECLARE
  v_config_id UUID;
  v_group_id UUID;
  v_analysis_group_id UUID;
BEGIN
  -- Get the active navigation config
  SELECT id INTO v_config_id
  FROM navigation_config
  WHERE is_active = true
  LIMIT 1;
  
  -- If no active config, get the first one
  IF v_config_id IS NULL THEN
    SELECT id INTO v_config_id
    FROM navigation_config
    ORDER BY created_at DESC
    LIMIT 1;
  END IF;
  
  -- If still no config and users exist, create a default one
  IF v_config_id IS NULL THEN
    IF EXISTS (SELECT 1 FROM auth.users LIMIT 1) THEN
      INSERT INTO navigation_config (name, description, is_active, created_by)
      VALUES ('Default Navigation', 'System default navigation', true, (SELECT id FROM auth.users LIMIT 1))
      RETURNING id INTO v_config_id;
    ELSE
      RAISE NOTICE 'No users exist yet, skipping navigation setup';
      RETURN;
    END IF;
  END IF;
  
  -- Find or create the "Analysis" or "Financial Analysis" group
  SELECT id INTO v_analysis_group_id
  FROM navigation_groups
  WHERE config_id = v_config_id
    AND (label ILIKE '%analysis%' OR label ILIKE '%financial%')
  LIMIT 1;
  
  -- If no analysis group exists, create one
  IF v_analysis_group_id IS NULL THEN
    INSERT INTO navigation_groups (
      config_id,
      label,
      icon,
      display_order,
      is_visible,
      is_collapsible,
      context_scope
    ) VALUES (
      v_config_id,
      'Financial Analysis',
      'TrendingUp',
      50,
      true,
      true,
      'model'
    ) RETURNING id INTO v_analysis_group_id;
  END IF;
  
  -- Add P&L item if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM navigation_items 
    WHERE group_id = v_analysis_group_id 
      AND label = 'P&L Analysis'
  ) THEN
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
      metadata
    ) VALUES (
      v_analysis_group_id,
      'P&L Analysis',
      '/projects/:projectId/rounds/:roundId/models/:modelId/pnl',
      'FileText',
      10,
      true,
      false,
      'model',
      true,
      '{"description": "Comprehensive Profit & Loss statement with operating results, EBITDA, EBIT, cash flow, and financial metrics"}'::jsonb
    );
  END IF;
  
  RAISE NOTICE 'P&L Analysis added to navigation successfully';
END $$;
