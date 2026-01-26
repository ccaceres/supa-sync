-- Create role-based access control system

-- Create app roles enum
CREATE TYPE public.app_role AS ENUM ('admin', 'manager', 'analyst', 'viewer');

-- Create permissions enum
CREATE TYPE public.permission_type AS ENUM (
  'projects.view', 'projects.create', 'projects.edit', 'projects.delete',
  'models.view', 'models.create', 'models.edit', 'models.approve',
  'customers.view', 'customers.create', 'customers.edit', 'customers.delete',
  'library.view', 'library.create', 'library.edit', 'library.delete',
  'users.view', 'users.create', 'users.edit', 'users.delete',
  'approvals.view', 'approvals.create', 'approvals.manage', 'approvals.approve',
  'system.admin'
);

-- Create user roles table (junction table for multiple roles per user)
CREATE TABLE public.user_roles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  role app_role NOT NULL,
  assigned_by UUID,
  assigned_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  expires_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN NOT NULL DEFAULT true,
  UNIQUE(user_id, role)
);

-- Create role permissions table (defines what each role can do)
CREATE TABLE public.role_permissions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  role app_role NOT NULL,
  permission permission_type NOT NULL,
  UNIQUE(role, permission)
);

-- Create project assignments table (which users can access which projects)
CREATE TABLE public.project_assignments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID NOT NULL,
  user_id UUID NOT NULL,
  assigned_by UUID,
  assigned_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  access_level TEXT NOT NULL DEFAULT 'read', -- 'read', 'write', 'admin'
  is_active BOOLEAN NOT NULL DEFAULT true,
  UNIQUE(project_id, user_id)
);

-- Enable RLS on all new tables
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_assignments ENABLE ROW LEVEL SECURITY;

-- Insert default role permissions
INSERT INTO public.role_permissions (role, permission) VALUES
-- Admin permissions (full access)
('admin', 'projects.view'), ('admin', 'projects.create'), ('admin', 'projects.edit'), ('admin', 'projects.delete'),
('admin', 'models.view'), ('admin', 'models.create'), ('admin', 'models.edit'), ('admin', 'models.approve'),
('admin', 'customers.view'), ('admin', 'customers.create'), ('admin', 'customers.edit'), ('admin', 'customers.delete'),
('admin', 'library.view'), ('admin', 'library.create'), ('admin', 'library.edit'), ('admin', 'library.delete'),
('admin', 'users.view'), ('admin', 'users.create'), ('admin', 'users.edit'), ('admin', 'users.delete'),
('admin', 'system.admin'),

-- Manager permissions
('manager', 'projects.view'), ('manager', 'projects.create'), ('manager', 'projects.edit'),
('manager', 'models.view'), ('manager', 'models.create'), ('manager', 'models.edit'), ('manager', 'models.approve'),
('manager', 'customers.view'), ('manager', 'customers.create'), ('manager', 'customers.edit'),
('manager', 'library.view'),

-- Analyst permissions
('analyst', 'projects.view'), ('analyst', 'models.view'), ('analyst', 'models.create'), ('analyst', 'models.edit'),
('analyst', 'customers.view'), ('analyst', 'library.view'),

-- Viewer permissions (read-only)
('viewer', 'projects.view'), ('viewer', 'models.view'), ('viewer', 'customers.view'), ('viewer', 'library.view');

-- Create security definer functions for role checking
CREATE OR REPLACE FUNCTION public.get_user_roles(user_uuid UUID DEFAULT auth.uid())
RETURNS SETOF app_role
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT role 
  FROM public.user_roles 
  WHERE user_id = user_uuid 
    AND is_active = true 
    AND (expires_at IS NULL OR expires_at > now())
$$;

CREATE OR REPLACE FUNCTION public.has_role(user_uuid UUID, target_role app_role)
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 
    FROM public.user_roles 
    WHERE user_id = user_uuid 
      AND role = target_role 
      AND is_active = true 
      AND (expires_at IS NULL OR expires_at > now())
  )
$$;

CREATE OR REPLACE FUNCTION public.has_permission(user_uuid UUID, target_permission permission_type)
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 
    FROM public.user_roles ur
    JOIN public.role_permissions rp ON ur.role = rp.role
    WHERE ur.user_id = user_uuid 
      AND rp.permission = target_permission
      AND ur.is_active = true 
      AND (ur.expires_at IS NULL OR ur.expires_at > now())
  )
$$;

CREATE OR REPLACE FUNCTION public.can_access_project(user_uuid UUID, target_project_id UUID)
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    -- User is project owner
    SELECT 1 FROM public.projects WHERE id = target_project_id AND created_by = user_uuid
  ) OR EXISTS (
    -- User has explicit project assignment
    SELECT 1 FROM public.project_assignments 
    WHERE project_id = target_project_id AND user_id = user_uuid AND is_active = true
  ) OR EXISTS (
    -- User is admin
    SELECT 1 FROM public.user_roles 
    WHERE user_id = user_uuid AND role = 'admin' AND is_active = true
  )
$$;

-- RLS Policies for new tables
CREATE POLICY "Users can view their own roles" ON public.user_roles
  FOR SELECT USING (user_id = auth.uid() OR public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can manage user roles" ON public.user_roles
  FOR ALL USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Anyone can view role permissions" ON public.role_permissions
  FOR SELECT USING (true);

CREATE POLICY "Admins can manage role permissions" ON public.role_permissions
  FOR ALL USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Users can view project assignments they're involved in" ON public.project_assignments
  FOR SELECT USING (
    user_id = auth.uid() OR 
    assigned_by = auth.uid() OR 
    public.has_role(auth.uid(), 'admin') OR
    public.can_access_project(auth.uid(), project_id)
  );

CREATE POLICY "Managers and admins can create project assignments" ON public.project_assignments
  FOR INSERT WITH CHECK (
    public.has_permission(auth.uid(), 'projects.edit') OR 
    public.has_role(auth.uid(), 'admin')
  );

-- Update existing projects RLS policy to use new permission system
DROP POLICY IF EXISTS "Users can view all projects" ON public.projects;
CREATE POLICY "Users can view projects based on permissions" ON public.projects
  FOR SELECT USING (
    created_by = auth.uid() OR
    public.can_access_project(auth.uid(), id) OR
    public.has_permission(auth.uid(), 'projects.view')
  );

-- Give the first user (if exists) admin role
DO $$
DECLARE
    first_user_id UUID;
BEGIN
    SELECT user_id INTO first_user_id FROM public.profiles ORDER BY created_at ASC LIMIT 1;
    
    IF first_user_id IS NOT NULL THEN
        INSERT INTO public.user_roles (user_id, role, assigned_by)
        VALUES (first_user_id, 'admin', first_user_id)
        ON CONFLICT (user_id, role) DO NOTHING;
    END IF;
END $$;