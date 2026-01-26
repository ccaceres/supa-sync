-- Insert My Teams navigation group
INSERT INTO navigation_groups (config_id, label, icon, display_order, is_visible, is_collapsible)
SELECT 
  id,
  'My Teams',
  'UsersRound',
  1,
  true,
  true
FROM navigation_config 
WHERE name = 'Default Navigation';

-- Update display order for Administration group
UPDATE navigation_groups 
SET display_order = 2 
WHERE label = 'Administration' 
  AND config_id = (SELECT id FROM navigation_config WHERE name = 'Default Navigation');

-- Update display order for System group
UPDATE navigation_groups 
SET display_order = 3 
WHERE label = 'System'
  AND config_id = (SELECT id FROM navigation_config WHERE name = 'Default Navigation');