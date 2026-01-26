-- Ensure RLS is enabled
ALTER TABLE IF EXISTS public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.team_members ENABLE ROW LEVEL SECURITY;

-- Helper function to check membership without referencing team_members in teams policy directly
-- Note: Do NOT use this in team_members policies to avoid recursion
CREATE OR REPLACE FUNCTION public.is_member_of_team(
  p_team_id uuid,
  p_user_id uuid DEFAULT auth.uid()
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.team_members tm
    WHERE tm.team_id = p_team_id
      AND tm.user_id = p_user_id
      AND tm.is_active = true
  );
$$;

-- Clean up existing possibly-conflicting policies on team_members
DROP POLICY IF EXISTS "Users can view team members for teams they belong to" ON public.team_members;
DROP POLICY IF EXISTS "Admins can insert team members" ON public.team_members;
DROP POLICY IF EXISTS "Admins can update team members" ON public.team_members;
DROP POLICY IF EXISTS "Admins can view all team members" ON public.team_members;
DROP POLICY IF EXISTS "team_members_infinite_recursion_fix" ON public.team_members;
DROP POLICY IF EXISTS "Team members: user can view own membership" ON public.team_members;
DROP POLICY IF EXISTS "Team members: admin full access" ON public.team_members;

-- Safe, non-recursive policies for team_members
-- Admins: full access
CREATE POLICY "Team members: admin full access"
ON public.team_members
FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Regular users: can view their own membership rows only
CREATE POLICY "Team members: users can view own membership"
ON public.team_members
FOR SELECT
USING (auth.uid() = user_id);

-- Clean up existing possibly-conflicting policies on teams
DROP POLICY IF EXISTS "Admins can create teams" ON public.teams;
DROP POLICY IF EXISTS "Admins can update teams" ON public.teams;
DROP POLICY IF EXISTS "Authenticated users can view active teams" ON public.teams;
DROP POLICY IF EXISTS "Teams: admin manage" ON public.teams;
DROP POLICY IF EXISTS "Teams: members can view active teams" ON public.teams;

-- Admins manage teams
CREATE POLICY "Teams: admin manage"
ON public.teams
FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Members can view active teams they belong to
CREATE POLICY "Teams: members can view active teams"
ON public.teams
FOR SELECT
USING (
  is_active = true AND (
    has_role(auth.uid(), 'admin'::app_role)
    OR public.is_member_of_team(id, auth.uid())
  )
);

-- Performance indexes
CREATE INDEX IF NOT EXISTS idx_teams_is_active_level_name ON public.teams (is_active, level, name);
CREATE INDEX IF NOT EXISTS idx_teams_parent_team_id ON public.teams (parent_team_id) WHERE parent_team_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_team_members_team_active ON public.team_members (team_id, is_active);
CREATE INDEX IF NOT EXISTS idx_team_members_user_active_team ON public.team_members (user_id, is_active, team_id);
