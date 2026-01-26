-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create user profiles table for additional user information
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  role TEXT DEFAULT 'User' CHECK (role IN ('Admin', 'Manager', 'User', 'Viewer')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create profiles policies
CREATE POLICY "Users can view all profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Projects table
CREATE TABLE public.projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  customer VARCHAR(255),
  status VARCHAR(50) DEFAULT 'Active' CHECK (status IN ('Active', 'Archived')),
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on projects
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

-- Projects policies
CREATE POLICY "Users can view all projects" ON public.projects FOR SELECT USING (true);
CREATE POLICY "Users can create projects" ON public.projects FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Users can update projects they created" ON public.projects FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Users can delete projects they created" ON public.projects FOR DELETE USING (auth.uid() = created_by);

-- Models table
CREATE TABLE public.models (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  version INTEGER DEFAULT 1,
  status VARCHAR(50) DEFAULT 'Draft' CHECK (status IN ('Draft', 'Submitted', 'Approved')),
  is_lead BOOLEAN DEFAULT FALSE,
  locked_by UUID REFERENCES auth.users(id),
  locked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on models
ALTER TABLE public.models ENABLE ROW LEVEL SECURITY;

-- Models policies
CREATE POLICY "Users can view models from accessible projects" ON public.models FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.projects WHERE id = project_id)
);
CREATE POLICY "Users can create models in their projects" ON public.models FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.projects WHERE id = project_id AND created_by = auth.uid())
);
CREATE POLICY "Users can update models in their projects" ON public.models FOR UPDATE USING (
  EXISTS (SELECT 1 FROM public.projects WHERE id = project_id AND created_by = auth.uid())
);
CREATE POLICY "Users can delete models in their projects" ON public.models FOR DELETE USING (
  EXISTS (SELECT 1 FROM public.projects WHERE id = project_id AND created_by = auth.uid())
);

-- Model parameters table
CREATE TABLE public.model_parameters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES public.models(id) ON DELETE CASCADE,
  parameter_type VARCHAR(50) NOT NULL CHECK (parameter_type IN ('basic', 'finance', 'operations')),
  data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(model_id, parameter_type)
);

-- Enable RLS on model_parameters
ALTER TABLE public.model_parameters ENABLE ROW LEVEL SECURITY;

-- Model parameters policies
CREATE POLICY "Users can manage parameters for accessible models" ON public.model_parameters FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.models m 
    JOIN public.projects p ON m.project_id = p.id 
    WHERE m.id = model_id AND p.created_by = auth.uid()
  )
);

-- Volumes table
CREATE TABLE public.volumes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES public.models(id) ON DELETE CASCADE,
  service_line VARCHAR(255) NOT NULL,
  year_1 DECIMAL(15,2) DEFAULT 0,
  year_2 DECIMAL(15,2) DEFAULT 0,
  year_3 DECIMAL(15,2) DEFAULT 0,
  year_4 DECIMAL(15,2) DEFAULT 0,
  year_5 DECIMAL(15,2) DEFAULT 0,
  year_6 DECIMAL(15,2) DEFAULT 0,
  year_7 DECIMAL(15,2) DEFAULT 0,
  year_8 DECIMAL(15,2) DEFAULT 0,
  year_9 DECIMAL(15,2) DEFAULT 0,
  year_10 DECIMAL(15,2) DEFAULT 0,
  price_1 DECIMAL(15,2) DEFAULT 0,
  price_2 DECIMAL(15,2) DEFAULT 0,
  price_3 DECIMAL(15,2) DEFAULT 0,
  price_4 DECIMAL(15,2) DEFAULT 0,
  price_5 DECIMAL(15,2) DEFAULT 0,
  price_6 DECIMAL(15,2) DEFAULT 0,
  price_7 DECIMAL(15,2) DEFAULT 0,
  price_8 DECIMAL(15,2) DEFAULT 0,
  price_9 DECIMAL(15,2) DEFAULT 0,
  price_10 DECIMAL(15,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on volumes
ALTER TABLE public.volumes ENABLE ROW LEVEL SECURITY;

-- Volumes policies
CREATE POLICY "Users can manage volumes for accessible models" ON public.volumes FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.models m 
    JOIN public.projects p ON m.project_id = p.id 
    WHERE m.id = model_id AND p.created_by = auth.uid()
  )
);

-- Direct roles table
CREATE TABLE public.direct_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES public.models(id) ON DELETE CASCADE,
  role_name VARCHAR(255) NOT NULL,
  hourly_rate DECIMAL(15,2) DEFAULT 0,
  hours_year_1 DECIMAL(15,2) DEFAULT 0,
  hours_year_2 DECIMAL(15,2) DEFAULT 0,
  hours_year_3 DECIMAL(15,2) DEFAULT 0,
  hours_year_4 DECIMAL(15,2) DEFAULT 0,
  hours_year_5 DECIMAL(15,2) DEFAULT 0,
  hours_year_6 DECIMAL(15,2) DEFAULT 0,
  hours_year_7 DECIMAL(15,2) DEFAULT 0,
  hours_year_8 DECIMAL(15,2) DEFAULT 0,
  hours_year_9 DECIMAL(15,2) DEFAULT 0,
  hours_year_10 DECIMAL(15,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on direct_roles
ALTER TABLE public.direct_roles ENABLE ROW LEVEL SECURITY;

-- Direct roles policies
CREATE POLICY "Users can manage direct roles for accessible models" ON public.direct_roles FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.models m 
    JOIN public.projects p ON m.project_id = p.id 
    WHERE m.id = model_id AND p.created_by = auth.uid()
  )
);

-- Salary roles table
CREATE TABLE public.salary_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES public.models(id) ON DELETE CASCADE,
  role_name VARCHAR(255) NOT NULL,
  annual_salary DECIMAL(15,2) DEFAULT 0,
  fte_year_1 DECIMAL(5,2) DEFAULT 0,
  fte_year_2 DECIMAL(5,2) DEFAULT 0,
  fte_year_3 DECIMAL(5,2) DEFAULT 0,
  fte_year_4 DECIMAL(5,2) DEFAULT 0,
  fte_year_5 DECIMAL(5,2) DEFAULT 0,
  fte_year_6 DECIMAL(5,2) DEFAULT 0,
  fte_year_7 DECIMAL(5,2) DEFAULT 0,
  fte_year_8 DECIMAL(5,2) DEFAULT 0,
  fte_year_9 DECIMAL(5,2) DEFAULT 0,
  fte_year_10 DECIMAL(5,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on salary_roles
ALTER TABLE public.salary_roles ENABLE ROW LEVEL SECURITY;

-- Salary roles policies
CREATE POLICY "Users can manage salary roles for accessible models" ON public.salary_roles FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.models m 
    JOIN public.projects p ON m.project_id = p.id 
    WHERE m.id = model_id AND p.created_by = auth.uid()
  )
);

-- Equipment table
CREATE TABLE public.equipment (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES public.models(id) ON DELETE CASCADE,
  equipment_name VARCHAR(255) NOT NULL,
  equipment_type VARCHAR(100),
  unit_cost DECIMAL(15,2) DEFAULT 0,
  quantity DECIMAL(15,2) DEFAULT 0,
  depreciation_years INTEGER DEFAULT 5,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on equipment
ALTER TABLE public.equipment ENABLE ROW LEVEL SECURITY;

-- Equipment policies
CREATE POLICY "Users can manage equipment for accessible models" ON public.equipment FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.models m 
    JOIN public.projects p ON m.project_id = p.id 
    WHERE m.id = model_id AND p.created_by = auth.uid()
  )
);

-- OPEX lines table
CREATE TABLE public.opex_lines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES public.models(id) ON DELETE CASCADE,
  category VARCHAR(255) NOT NULL,
  description TEXT,
  cost_year_1 DECIMAL(15,2) DEFAULT 0,
  cost_year_2 DECIMAL(15,2) DEFAULT 0,
  cost_year_3 DECIMAL(15,2) DEFAULT 0,
  cost_year_4 DECIMAL(15,2) DEFAULT 0,
  cost_year_5 DECIMAL(15,2) DEFAULT 0,
  cost_year_6 DECIMAL(15,2) DEFAULT 0,
  cost_year_7 DECIMAL(15,2) DEFAULT 0,
  cost_year_8 DECIMAL(15,2) DEFAULT 0,
  cost_year_9 DECIMAL(15,2) DEFAULT 0,
  cost_year_10 DECIMAL(15,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on opex_lines
ALTER TABLE public.opex_lines ENABLE ROW LEVEL SECURITY;

-- OPEX policies
CREATE POLICY "Users can manage opex for accessible models" ON public.opex_lines FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.models m 
    JOIN public.projects p ON m.project_id = p.id 
    WHERE m.id = model_id AND p.created_by = auth.uid()
  )
);

-- CAPEX lines table
CREATE TABLE public.capex_lines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES public.models(id) ON DELETE CASCADE,
  category VARCHAR(255) NOT NULL,
  description TEXT,
  cost_year_1 DECIMAL(15,2) DEFAULT 0,
  cost_year_2 DECIMAL(15,2) DEFAULT 0,
  cost_year_3 DECIMAL(15,2) DEFAULT 0,
  cost_year_4 DECIMAL(15,2) DEFAULT 0,
  cost_year_5 DECIMAL(15,2) DEFAULT 0,
  cost_year_6 DECIMAL(15,2) DEFAULT 0,
  cost_year_7 DECIMAL(15,2) DEFAULT 0,
  cost_year_8 DECIMAL(15,2) DEFAULT 0,
  cost_year_9 DECIMAL(15,2) DEFAULT 0,
  cost_year_10 DECIMAL(15,2) DEFAULT 0,
  depreciation_years INTEGER DEFAULT 5,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on capex_lines
ALTER TABLE public.capex_lines ENABLE ROW LEVEL SECURITY;

-- CAPEX policies
CREATE POLICY "Users can manage capex for accessible models" ON public.capex_lines FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.models m 
    JOIN public.projects p ON m.project_id = p.id 
    WHERE m.id = model_id AND p.created_by = auth.uid()
  )
);

-- IMPEX lines table
CREATE TABLE public.impex_lines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES public.models(id) ON DELETE CASCADE,
  category VARCHAR(255) NOT NULL,
  description TEXT,
  driver_type VARCHAR(100), -- e.g., 'per_unit', 'percentage', 'fixed'
  driver_value DECIMAL(15,2) DEFAULT 0,
  cost_year_1 DECIMAL(15,2) DEFAULT 0,
  cost_year_2 DECIMAL(15,2) DEFAULT 0,
  cost_year_3 DECIMAL(15,2) DEFAULT 0,
  cost_year_4 DECIMAL(15,2) DEFAULT 0,
  cost_year_5 DECIMAL(15,2) DEFAULT 0,
  cost_year_6 DECIMAL(15,2) DEFAULT 0,
  cost_year_7 DECIMAL(15,2) DEFAULT 0,
  cost_year_8 DECIMAL(15,2) DEFAULT 0,
  cost_year_9 DECIMAL(15,2) DEFAULT 0,
  cost_year_10 DECIMAL(15,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on impex_lines
ALTER TABLE public.impex_lines ENABLE ROW LEVEL SECURITY;

-- IMPEX policies
CREATE POLICY "Users can manage impex for accessible models" ON public.impex_lines FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.models m 
    JOIN public.projects p ON m.project_id = p.id 
    WHERE m.id = model_id AND p.created_by = auth.uid()
  )
);

-- Audit log table
CREATE TABLE public.audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  model_id UUID REFERENCES public.models(id),
  action VARCHAR(50) NOT NULL,
  entity_type VARCHAR(50) NOT NULL,
  entity_id UUID,
  old_values JSONB,
  new_values JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on audit_log
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

-- Audit log policies
CREATE POLICY "Users can view audit logs for accessible models" ON public.audit_log FOR SELECT USING (
  user_id = auth.uid() OR 
  EXISTS (
    SELECT 1 FROM public.models m 
    JOIN public.projects p ON m.project_id = p.id 
    WHERE m.id = model_id AND p.created_by = auth.uid()
  )
);

-- Function to automatically create user profile
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (user_id, full_name)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to automatically create profile on user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add update triggers to all tables
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON public.projects FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_models_updated_at BEFORE UPDATE ON public.models FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_model_parameters_updated_at BEFORE UPDATE ON public.model_parameters FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_volumes_updated_at BEFORE UPDATE ON public.volumes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_direct_roles_updated_at BEFORE UPDATE ON public.direct_roles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_salary_roles_updated_at BEFORE UPDATE ON public.salary_roles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_equipment_updated_at BEFORE UPDATE ON public.equipment FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_opex_lines_updated_at BEFORE UPDATE ON public.opex_lines FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_capex_lines_updated_at BEFORE UPDATE ON public.capex_lines FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_impex_lines_updated_at BEFORE UPDATE ON public.impex_lines FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();