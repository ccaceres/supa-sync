-- Update existing team member roles to simplified structure
-- Map director -> manager, approver -> manager, leader -> lead
UPDATE team_members 
SET role = CASE 
  WHEN role = 'director' THEN 'manager'
  WHEN role = 'approver' THEN 'manager'  
  WHEN role = 'leader' THEN 'lead'
  ELSE role
END
WHERE role IN ('director', 'approver', 'leader');

-- Add a comment to document the simplified role structure
COMMENT ON COLUMN team_members.role IS 'Simplified team roles: member (basic), lead (team lead), manager (team manager). Use is_approver flag for approval authority.';