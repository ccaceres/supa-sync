-- Create customers table
CREATE TABLE public.customers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL,
  code VARCHAR(5) NOT NULL UNIQUE,
  industry VARCHAR,
  country VARCHAR NOT NULL,
  contact_name VARCHAR,
  contact_email VARCHAR,
  contract_type VARCHAR,
  status VARCHAR NOT NULL DEFAULT 'Active',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS for customers
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

-- Create policies for customers
CREATE POLICY "Users can view all customers" 
ON public.customers 
FOR SELECT 
USING (true);

CREATE POLICY "Users can create customers" 
ON public.customers 
FOR INSERT 
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update customers" 
ON public.customers 
FOR UPDATE 
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can delete customers" 
ON public.customers 
FOR DELETE 
USING (auth.uid() IS NOT NULL);

-- Add trigger for customers updated_at
CREATE TRIGGER update_customers_updated_at
BEFORE UPDATE ON public.customers
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Add missing columns to projects table
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS customer_id UUID REFERENCES public.customers(id);
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS code VARCHAR;
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS type VARCHAR DEFAULT 'New Business';
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS opportunity_value NUMERIC;
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS probability INTEGER;
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS expected_revenue NUMERIC;
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS start_date DATE;
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS end_date DATE;
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS decision_date DATE;
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS country VARCHAR;
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS state VARCHAR;
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS city VARCHAR;
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS site_name VARCHAR;
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS owned_by UUID;
ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS archived_at TIMESTAMP WITH TIME ZONE;

-- Add trigger for projects if not exists
DROP TRIGGER IF EXISTS update_projects_updated_at ON public.projects;
CREATE TRIGGER update_projects_updated_at
BEFORE UPDATE ON public.projects
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Add missing columns to models table
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS major_version INTEGER DEFAULT 1;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS minor_version INTEGER DEFAULT 0;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS patch_version INTEGER DEFAULT 0;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS version_notes TEXT;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS copied_from_id UUID REFERENCES public.models(id);
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS copy_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS locked BOOLEAN DEFAULT false;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS lock_reason TEXT;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS submitted_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS closed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS last_modified_by UUID;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS approved_by UUID;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS total_revenue NUMERIC;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS total_cost NUMERIC;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS ebitda NUMERIC;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS margin_percentage NUMERIC;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS irr NUMERIC;
ALTER TABLE public.models ADD COLUMN IF NOT EXISTS npv NUMERIC;

-- Add trigger for models if not exists
DROP TRIGGER IF EXISTS update_models_updated_at ON public.models;
CREATE TRIGGER update_models_updated_at
BEFORE UPDATE ON public.models
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Create project types enum table
CREATE TABLE IF NOT EXISTS public.project_types (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Insert default project types
INSERT INTO public.project_types (name, description) VALUES
('New Business', 'New business opportunity'),
('Expansion', 'Expansion of existing business'),
('Renewal', 'Contract renewal'),
('RFP Response', 'Response to Request for Proposal'),
('Budget Planning', 'Internal budget planning'),
('Feasibility Study', 'Feasibility analysis')
ON CONFLICT (name) DO NOTHING;

-- Enable RLS for project_types
ALTER TABLE public.project_types ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view project types" 
ON public.project_types 
FOR SELECT 
USING (true);

-- Create countries lookup table
CREATE TABLE IF NOT EXISTS public.countries (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL UNIQUE,
  code VARCHAR(3) NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Insert common countries
INSERT INTO public.countries (name, code) VALUES
('United States', 'USA'),
('Canada', 'CAN'),
('United Kingdom', 'GBR'),
('Germany', 'DEU'),
('France', 'FRA'),
('Netherlands', 'NLD'),
('Australia', 'AUS'),
('New Zealand', 'NZL')
ON CONFLICT (name) DO NOTHING;

-- Enable RLS for countries
ALTER TABLE public.countries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view countries" 
ON public.countries 
FOR SELECT 
USING (true);

-- Create industries lookup table
CREATE TABLE IF NOT EXISTS public.industries (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Insert common industries
INSERT INTO public.industries (name, description) VALUES
('Aviation', 'Airlines and aviation services'),
('Healthcare', 'Healthcare and medical services'),
('Manufacturing', 'Manufacturing and production'),
('Technology', 'Technology and software'),
('Finance', 'Financial services'),
('Energy', 'Energy and utilities'),
('Retail', 'Retail and consumer goods'),
('Logistics', 'Logistics and transportation')
ON CONFLICT (name) DO NOTHING;

-- Enable RLS for industries
ALTER TABLE public.industries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view industries" 
ON public.industries 
FOR SELECT 
USING (true);