-- Add URL template support to navigation_items
ALTER TABLE navigation_items 
ADD COLUMN IF NOT EXISTS url_type VARCHAR DEFAULT 'static' CHECK (url_type IN ('static', 'project', 'model')),
ADD COLUMN IF NOT EXISTS context_required BOOLEAN DEFAULT false;

-- Add context scope to navigation_groups
ALTER TABLE navigation_groups
ADD COLUMN IF NOT EXISTS context_scope VARCHAR DEFAULT 'global' CHECK (context_scope IN ('global', 'project', 'model'));

-- Seed model-specific navigation structure
DO $$
DECLARE
  v_config_id UUID;
  v_project_group_id UUID;
  v_modeling_group_id UUID;
  v_financial_group_id UUID;
BEGIN
  -- Get active config or create one
  SELECT id INTO v_config_id FROM navigation_config WHERE is_active = true LIMIT 1;
  
  IF v_config_id IS NULL THEN
    -- Use first user if exists, otherwise skip
    IF EXISTS (SELECT 1 FROM auth.users LIMIT 1) THEN
      INSERT INTO navigation_config (name, description, is_active, created_by)
      VALUES ('Default Configuration', 'System default navigation', true, (SELECT id FROM auth.users LIMIT 1))
      RETURNING id INTO v_config_id;
    ELSE
      RETURN; -- Exit early if no users exist
    END IF;
  END IF;
  
  -- Create Project group
  INSERT INTO navigation_groups (config_id, label, icon, display_order, context_scope, is_visible, is_collapsible)
  VALUES (v_config_id, 'Project', 'FolderKanban', 100, 'project', true, true)
  RETURNING id INTO v_project_group_id;
  
  -- Create Modeling group
  INSERT INTO navigation_groups (config_id, label, icon, display_order, context_scope, is_visible, is_collapsible)
  VALUES (v_config_id, 'Modeling', 'Calculator', 200, 'model', true, true)
  RETURNING id INTO v_modeling_group_id;
  
  -- Create Financials group
  INSERT INTO navigation_groups (config_id, label, icon, display_order, context_scope, is_visible, is_collapsible)
  VALUES (v_config_id, 'Financials', 'DollarSign', 300, 'model', true, true)
  RETURNING id INTO v_financial_group_id;
  
  -- Insert Project items
  INSERT INTO navigation_items (group_id, label, url, icon, display_order, url_type, context_required, is_visible)
  VALUES 
    (v_project_group_id, 'Executive Dashboard', '/projects/{projectId}/dashboard', 'BarChart3', 1, 'project', true, true),
    (v_project_group_id, 'Rounds', '/projects/{projectId}/rounds', 'GitBranch', 2, 'project', true, true);
  
  -- Insert Modeling items
  INSERT INTO navigation_items (group_id, label, url, icon, display_order, url_type, context_required, is_visible)
  VALUES 
    (v_modeling_group_id, 'Parameters', '/projects/{projectId}/rounds/{roundId}/models/{modelId}/parameters', 'Settings', 1, 'model', true, true),
    (v_modeling_group_id, 'Volumes', '/projects/{projectId}/rounds/{roundId}/models/{modelId}/volumes', 'TrendingUp', 2, 'model', true, true),
    (v_modeling_group_id, 'Exempt Positions', '/projects/{projectId}/rounds/{roundId}/models/{modelId}/exempt', 'UserCheck', 3, 'model', true, true),
    (v_modeling_group_id, 'Non-Exempt Positions', '/projects/{projectId}/rounds/{roundId}/models/{modelId}/nonexempt', 'Users', 4, 'model', true, true),
    (v_modeling_group_id, 'Direct Labor', '/projects/{projectId}/rounds/{roundId}/models/{modelId}/direct-labor', 'Hammer', 5, 'model', true, true),
    (v_modeling_group_id, 'Equipment', '/projects/{projectId}/rounds/{roundId}/models/{modelId}/equipment', 'Wrench', 6, 'model', true, true);
  
  -- Insert Financial items
  INSERT INTO navigation_items (group_id, label, url, icon, display_order, url_type, context_required, is_visible)
  VALUES 
    (v_financial_group_id, 'OPEX', '/projects/{projectId}/rounds/{roundId}/models/{modelId}/opex', 'Receipt', 1, 'model', true, true),
    (v_financial_group_id, 'CAPEX', '/projects/{projectId}/rounds/{roundId}/models/{modelId}/capex', 'Building', 2, 'model', true, true),
    (v_financial_group_id, 'IMPEX', '/projects/{projectId}/rounds/{roundId}/models/{modelId}/impex', 'FileText', 3, 'model', true, true),
    (v_financial_group_id, 'Outputs', '/projects/{projectId}/rounds/{roundId}/models/{modelId}/outputs', 'FileSpreadsheet', 4, 'model', true, true);
END $$;