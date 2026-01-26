-- Fix the profiles table security vulnerability
-- Current policy allows anyone to view all profiles, which exposes user personal information

-- Drop existing overly permissive policy
DROP POLICY IF EXISTS "Users can view all profiles" ON public.profiles;

-- Create secure policy: users can only view their own profile and admins can view all
CREATE POLICY "Users can view their own profile and admins can view all" 
ON public.profiles 
FOR SELECT 
USING (
  auth.uid() = user_id OR 
  has_role(auth.uid(), 'admin'::app_role)
);

-- Fix customers table RLS policies to use proper permissions
DROP POLICY IF EXISTS "Users can view all customers" ON public.customers;
DROP POLICY IF EXISTS "Users can create customers" ON public.customers;
DROP POLICY IF EXISTS "Users can update customers" ON public.customers;  
DROP POLICY IF EXISTS "Users can delete customers" ON public.customers;

CREATE POLICY "Users can view customers with permission" 
ON public.customers 
FOR SELECT 
USING (has_permission(auth.uid(), 'customers.view'::permission_type));

CREATE POLICY "Users can create customers with permission"
ON public.customers 
FOR INSERT 
WITH CHECK (has_permission(auth.uid(), 'customers.create'::permission_type));

CREATE POLICY "Users can update customers with permission"
ON public.customers 
FOR UPDATE 
USING (has_permission(auth.uid(), 'customers.edit'::permission_type));

CREATE POLICY "Users can delete customers with permission"
ON public.customers 
FOR DELETE 
USING (has_permission(auth.uid(), 'customers.delete'::permission_type));

-- Fix projects table RLS policies
DROP POLICY IF EXISTS "Users can view projects based on permissions" ON public.projects;
DROP POLICY IF EXISTS "Users can create projects" ON public.projects;
DROP POLICY IF EXISTS "Users can update projects they created" ON public.projects;
DROP POLICY IF EXISTS "Users can delete projects they created" ON public.projects;

CREATE POLICY "Users can view projects with permission" 
ON public.projects 
FOR SELECT 
USING (
  created_by = auth.uid() OR 
  can_access_project(auth.uid(), id) OR 
  has_permission(auth.uid(), 'projects.view'::permission_type)
);

CREATE POLICY "Users can create projects with permission"
ON public.projects 
FOR INSERT 
WITH CHECK (
  auth.uid() = created_by AND 
  has_permission(auth.uid(), 'projects.create'::permission_type)
);

CREATE POLICY "Users can update accessible projects with permission"
ON public.projects 
FOR UPDATE 
USING (
  (created_by = auth.uid() OR can_access_project(auth.uid(), id)) AND
  has_permission(auth.uid(), 'projects.edit'::permission_type)
);

CREATE POLICY "Users can delete accessible projects with permission"
ON public.projects 
FOR DELETE 
USING (
  (created_by = auth.uid() OR can_access_project(auth.uid(), id)) AND
  has_permission(auth.uid(), 'projects.delete'::permission_type)
);

-- Add missing customer permissions for existing roles
INSERT INTO public.role_permissions (role, permission) VALUES 
('admin', 'customers.view'),
('admin', 'customers.create'), 
('admin', 'customers.edit'),
('admin', 'customers.delete'),
('manager', 'customers.view'),
('manager', 'customers.create'),
('manager', 'customers.edit'), 
('manager', 'customers.delete'),
('analyst', 'customers.view'),
('analyst', 'customers.create'),
('analyst', 'customers.edit'),
('viewer', 'customers.view')
ON CONFLICT (role, permission) DO NOTHING;

-- Add missing project permissions for existing roles  
INSERT INTO public.role_permissions (role, permission) VALUES
('admin', 'projects.view'),
('admin', 'projects.create'),
('admin', 'projects.edit'), 
('admin', 'projects.delete'),
('manager', 'projects.view'),
('manager', 'projects.create'),
('manager', 'projects.edit'),
('manager', 'projects.delete'), 
('analyst', 'projects.view'),
('analyst', 'projects.create'),
('analyst', 'projects.edit'),
('viewer', 'projects.view')
ON CONFLICT (role, permission) DO NOTHING;