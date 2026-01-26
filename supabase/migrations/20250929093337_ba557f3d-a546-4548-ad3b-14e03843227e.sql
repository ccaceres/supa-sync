-- Fix existing team level inconsistencies
UPDATE teams 
SET level = CASE 
  WHEN parent_team_id IS NULL THEN 1
  ELSE (
    WITH RECURSIVE team_hierarchy AS (
      -- Base case: teams with no parent (top level)
      SELECT id, parent_team_id, 1 as level
      FROM teams 
      WHERE parent_team_id IS NULL
      
      UNION ALL
      
      -- Recursive case: teams with parents
      SELECT t.id, t.parent_team_id, th.level + 1
      FROM teams t
      INNER JOIN team_hierarchy th ON t.parent_team_id = th.id
    )
    SELECT level FROM team_hierarchy WHERE id = teams.id
  )
END
WHERE is_active = true;