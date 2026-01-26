-- Fix RLS policies for teams and team_members to allow proper access
-- Drop existing policies that might be causing issues
DROP POLICY IF EXISTS "team_members_infinite_recursion_fix" ON public.team_members;

-- Create proper INSERT and UPDATE policies for teams (use system.admin instead of non-existent teams.manage)
DROP POLICY IF EXISTS "Admins and managers can create teams" ON public.teams;
CREATE POLICY "Admins and managers can create teams"
ON public.teams
FOR INSERT
WITH CHECK (
  has_role(auth.uid(), 'admin'::app_role) OR
  has_permission(auth.uid(), 'system.admin'::permission_type)
);

DROP POLICY IF EXISTS "Admins and managers can update teams" ON public.teams;
CREATE POLICY "Admins and managers can update teams"
ON public.teams
FOR UPDATE
USING (
  has_role(auth.uid(), 'admin'::app_role) OR
  has_permission(auth.uid(), 'system.admin'::permission_type)
);

-- Create proper policies for team_members without recursion
DROP POLICY IF EXISTS "Team leaders and admins can insert team members" ON public.team_members;
CREATE POLICY "Team leaders and admins can insert team members"
ON public.team_members
FOR INSERT
WITH CHECK (
  has_role(auth.uid(), 'admin'::app_role) OR
  EXISTS (
    SELECT 1 FROM public.team_members tm
    WHERE tm.team_id = team_members.team_id
    AND tm.user_id = auth.uid()
    AND tm.is_approver = true
    AND tm.is_active = true
  )
);

DROP POLICY IF EXISTS "Team leaders and admins can update team members" ON public.team_members;
CREATE POLICY "Team leaders and admins can update team members"
ON public.team_members
FOR UPDATE
USING (
  has_role(auth.uid(), 'admin'::app_role) OR
  EXISTS (
    SELECT 1 FROM public.team_members tm
    WHERE tm.team_id = team_members.team_id
    AND tm.user_id = auth.uid()
    AND tm.is_approver = true
    AND tm.is_active = true
  )
);

DROP POLICY IF EXISTS "Users can view team members for teams they belong to" ON public.team_members;
CREATE POLICY "Users can view team members for teams they belong to"
ON public.team_members
FOR SELECT
USING (
  has_role(auth.uid(), 'admin'::app_role) OR
  EXISTS (
    SELECT 1 FROM public.team_members tm
    WHERE tm.team_id = team_members.team_id
    AND tm.user_id = auth.uid()
    AND tm.is_active = true
  )
);

-- Add performance indexes
CREATE INDEX IF NOT EXISTS idx_teams_is_active_level_name ON public.teams (is_active, level, name);
CREATE INDEX IF NOT EXISTS idx_teams_parent_team_id ON public.teams (parent_team_id) WHERE parent_team_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_team_members_team_active ON public.team_members (team_id, is_active);
CREATE INDEX IF NOT EXISTS idx_team_members_user_active_team ON public.team_members (user_id, is_active, team_id);
