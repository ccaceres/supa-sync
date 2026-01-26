-- Add Pricing navigation item and reorganize navigation structure

-- Step 1: Create Cost Input group
WITH active_config AS (
  SELECT id FROM navigation_config WHERE is_active = true LIMIT 1
)
INSERT INTO navigation_groups (
  config_id,
  label,
  icon,
  display_order,
  is_visible,
  is_collapsible,
  context_scope
)
SELECT 
  ac.id,
  'Cost Input',
  'Calculator',
  3,
  true,
  true,
  'model'
FROM active_config ac;

-- Step 2: Add LABEX to Cost Input group
WITH cost_input_group AS (
  SELECT id FROM navigation_groups WHERE label = 'Cost Input' LIMIT 1
)
INSERT INTO navigation_items (
  group_id,
  label,
  url,
  icon,
  display_order,
  is_visible,
  is_protected,
  url_type,
  context_required
)
SELECT 
  cig.id,
  'LABEX',
  '/projects/{projectId}/rounds/{roundId}/models/{modelId}/labex',
  'Users',
  1,
  true,
  false,
  'model',
  true
FROM cost_input_group cig;

-- Step 3: Move OPEX, CAPEX, IMPEX to Cost Input group
WITH cost_input_group AS (
  SELECT id FROM navigation_groups WHERE label = 'Cost Input' LIMIT 1
)
UPDATE navigation_items
SET group_id = (SELECT id FROM cost_input_group),
    display_order = CASE 
      WHEN label = 'OPEX' THEN 2
      WHEN label = 'CAPEX' THEN 3
      WHEN label = 'IMPEX' THEN 4
    END
WHERE label IN ('OPEX', 'CAPEX', 'IMPEX');

-- Step 4: Add Pricing to Financials group
WITH financials_group AS (
  SELECT id FROM navigation_groups WHERE label = 'Financials' LIMIT 1
)
INSERT INTO navigation_items (
  group_id,
  label,
  url,
  icon,
  display_order,
  is_visible,
  is_protected,
  url_type,
  context_required
)
SELECT 
  fg.id,
  'Pricing',
  '/projects/{projectId}/rounds/{roundId}/models/{modelId}/pricing',
  'DollarSign',
  1,
  true,
  false,
  'model',
  true
FROM financials_group fg;

-- Step 5: Update P&L Analysis order in Financials
WITH financials_group AS (
  SELECT id FROM navigation_groups WHERE label = 'Financials' LIMIT 1
)
UPDATE navigation_items
SET display_order = 2
WHERE group_id = (SELECT id FROM financials_group)
AND label = 'P&L Analysis';

-- Step 6: Hide Executive Dashboard
UPDATE navigation_items
SET is_visible = false
WHERE label = 'Executive Dashboard';

-- Step 7: Move Equipment to Modeling group
WITH modeling_group AS (
  SELECT id FROM navigation_groups WHERE label = 'Modeling' LIMIT 1
)
UPDATE navigation_items
SET group_id = (SELECT id FROM modeling_group),
    display_order = 3
WHERE label = 'Equipment';

-- Step 8: Delete invalid navigation items (exempt and outputs)
DELETE FROM navigation_items 
WHERE url LIKE '%/exempt' OR url LIKE '%/outputs';

-- Step 9: Update group display orders
UPDATE navigation_groups
SET display_order = CASE 
  WHEN label = 'Project' THEN 1
  WHEN label = 'Modeling' THEN 2
  WHEN label = 'Cost Input' THEN 3
  WHEN label = 'Financials' THEN 4
  WHEN label = 'Admin' THEN 5
  WHEN label = 'System' THEN 6
END
WHERE label IN ('Project', 'Modeling', 'Cost Input', 'Financials', 'Admin', 'System');