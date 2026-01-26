-- Create library tables for Object Library functionality

-- Library Schedules (Master work schedule templates)
CREATE TABLE public.library_schedules (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL,
  description TEXT,
  schedule_code VARCHAR NOT NULL UNIQUE,
  
  -- Schedule Configuration
  days_per_week INTEGER NOT NULL DEFAULT 5,
  hours_per_day NUMERIC NOT NULL DEFAULT 8,
  shifts_per_day INTEGER NOT NULL DEFAULT 1,
  
  -- Shift Details
  shift_1_start TIME,
  shift_1_end TIME,
  shift_2_start TIME,
  shift_2_end TIME,
  shift_3_start TIME,
  shift_3_end TIME,
  
  -- Working Days
  monday BOOLEAN NOT NULL DEFAULT true,
  tuesday BOOLEAN NOT NULL DEFAULT true,
  wednesday BOOLEAN NOT NULL DEFAULT true,
  thursday BOOLEAN NOT NULL DEFAULT true,
  friday BOOLEAN NOT NULL DEFAULT true,
  saturday BOOLEAN NOT NULL DEFAULT false,
  sunday BOOLEAN NOT NULL DEFAULT false,
  
  -- Overtime Rules
  overtime_threshold NUMERIC DEFAULT 40,
  overtime_multiplier NUMERIC DEFAULT 1.5,
  
  -- Metadata
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  
  -- Usage Tracking
  used_in_models INTEGER DEFAULT 0,
  last_used TIMESTAMP WITH TIME ZONE
);

-- Library Direct Roles (Master hourly role templates)
CREATE TABLE public.library_direct_roles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  role_code VARCHAR NOT NULL UNIQUE,
  role_name VARCHAR NOT NULL,
  role_category VARCHAR NOT NULL,
  description TEXT,
  
  -- Location
  country VARCHAR NOT NULL,
  state VARCHAR,
  city VARCHAR,
  
  -- Compensation
  currency VARCHAR NOT NULL DEFAULT 'USD',
  base_hourly_rate NUMERIC NOT NULL DEFAULT 0,
  
  -- Shift Differentials
  shift_2_adder NUMERIC DEFAULT 0,
  shift_3_adder NUMERIC DEFAULT 0,
  weekend_adder NUMERIC DEFAULT 0,
  
  -- Benefits & Costs
  fringe_percentage NUMERIC DEFAULT 0,
  overtime_fringe_percentage NUMERIC DEFAULT 0,
  cost_to_hire NUMERIC DEFAULT 0,
  training_hours NUMERIC DEFAULT 0,
  
  -- Productivity
  efficiency_factor NUMERIC DEFAULT 1.0,
  utilization_target NUMERIC DEFAULT 2080,
  
  -- Skills & Certifications
  required_skills TEXT[],
  required_certifications TEXT[],
  
  -- Metadata
  is_active BOOLEAN NOT NULL DEFAULT true,
  effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
  expiration_date DATE,
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Library Salary Roles (Master salaried position templates)
CREATE TABLE public.library_salary_roles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  role_code VARCHAR NOT NULL UNIQUE,
  role_name VARCHAR NOT NULL,
  role_category VARCHAR NOT NULL,
  department VARCHAR,
  description TEXT,
  
  -- Location
  country VARCHAR NOT NULL,
  state VARCHAR,
  city VARCHAR,
  
  -- Compensation
  currency VARCHAR NOT NULL DEFAULT 'USD',
  annual_salary NUMERIC NOT NULL DEFAULT 0,
  
  -- Benefits & Overhead
  benefits_percentage NUMERIC DEFAULT 0,
  overhead_percentage NUMERIC DEFAULT 0,
  bonus_target_percentage NUMERIC DEFAULT 0,
  
  -- Allocation
  allocation_method VARCHAR DEFAULT 'Direct',
  allocation_percentage NUMERIC,
  cost_center VARCHAR,
  
  -- Reporting Structure
  reports_to UUID REFERENCES library_salary_roles(id),
  direct_reports INTEGER DEFAULT 0,
  
  -- Requirements
  minimum_experience INTEGER DEFAULT 0,
  required_education TEXT,
  required_certifications TEXT[],
  
  -- Metadata
  is_active BOOLEAN NOT NULL DEFAULT true,
  grade_level VARCHAR,
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Library Equipment (Master equipment catalog)
CREATE TABLE public.library_equipment (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  equipment_code VARCHAR NOT NULL UNIQUE,
  equipment_name VARCHAR NOT NULL,
  category VARCHAR NOT NULL,
  manufacturer VARCHAR,
  model_number VARCHAR,
  description TEXT,
  
  -- Specifications
  capacity NUMERIC,
  capacity_unit VARCHAR,
  length NUMERIC,
  width NUMERIC,
  height NUMERIC,
  weight NUMERIC,
  power_requirement TEXT,
  
  -- Financial
  purchase_price NUMERIC NOT NULL DEFAULT 0,
  lease_monthly_rate NUMERIC,
  
  -- Depreciation
  depreciation_method VARCHAR DEFAULT 'Straight',
  useful_life_years INTEGER DEFAULT 5,
  salvage_value NUMERIC DEFAULT 0,
  
  -- Operating Costs
  maintenance_annual NUMERIC DEFAULT 0,
  insurance_annual NUMERIC DEFAULT 0,
  fuel_cost_per_hour NUMERIC,
  operator_required BOOLEAN DEFAULT false,
  
  -- Availability
  lead_time_days INTEGER DEFAULT 30,
  availability_percentage NUMERIC DEFAULT 95,
  
  -- Requirements
  requires_certification BOOLEAN DEFAULT false,
  certification_type VARCHAR,
  space_required_sqft NUMERIC,
  
  -- Metadata
  is_active BOOLEAN NOT NULL DEFAULT true,
  discontinued BOOLEAN DEFAULT false,
  replacement_model VARCHAR,
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Library Object Usage (Track where library objects are used)
CREATE TABLE public.library_object_usage (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  library_object_id UUID NOT NULL,
  library_object_type VARCHAR NOT NULL,
  model_id UUID NOT NULL REFERENCES models(id) ON DELETE CASCADE,
  model_object_id UUID NOT NULL,
  
  -- Sync Information
  is_modified BOOLEAN DEFAULT false,
  last_synced TIMESTAMP WITH TIME ZONE,
  sync_version INTEGER DEFAULT 1,
  
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  
  UNIQUE(library_object_id, library_object_type, model_id)
);

-- Add library_source_id to existing model tables
ALTER TABLE public.direct_roles ADD COLUMN library_source_id UUID REFERENCES library_direct_roles(id);
ALTER TABLE public.salary_roles ADD COLUMN library_source_id UUID REFERENCES library_salary_roles(id);
ALTER TABLE public.equipment ADD COLUMN library_source_id UUID REFERENCES library_equipment(id);

-- Add schedule_id to role tables to link to schedules
ALTER TABLE public.direct_roles ADD COLUMN schedule_id UUID REFERENCES library_schedules(id);
ALTER TABLE public.salary_roles ADD COLUMN schedule_id UUID REFERENCES library_schedules(id);

-- Enable Row Level Security
ALTER TABLE public.library_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.library_direct_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.library_salary_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.library_equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.library_object_usage ENABLE ROW LEVEL SECURITY;

-- Create policies for library tables
CREATE POLICY "Users can view all library schedules" 
ON public.library_schedules FOR SELECT USING (true);

CREATE POLICY "Users can create library schedules" 
ON public.library_schedules FOR INSERT 
WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update library schedules they created" 
ON public.library_schedules FOR UPDATE 
USING (auth.uid() = created_by);

CREATE POLICY "Users can delete library schedules they created" 
ON public.library_schedules FOR DELETE 
USING (auth.uid() = created_by);

-- Similar policies for direct roles
CREATE POLICY "Users can view all library direct roles" 
ON public.library_direct_roles FOR SELECT USING (true);

CREATE POLICY "Users can create library direct roles" 
ON public.library_direct_roles FOR INSERT 
WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update library direct roles they created" 
ON public.library_direct_roles FOR UPDATE 
USING (auth.uid() = created_by);

CREATE POLICY "Users can delete library direct roles they created" 
ON public.library_direct_roles FOR DELETE 
USING (auth.uid() = created_by);

-- Similar policies for salary roles
CREATE POLICY "Users can view all library salary roles" 
ON public.library_salary_roles FOR SELECT USING (true);

CREATE POLICY "Users can create library salary roles" 
ON public.library_salary_roles FOR INSERT 
WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update library salary roles they created" 
ON public.library_salary_roles FOR UPDATE 
USING (auth.uid() = created_by);

CREATE POLICY "Users can delete library salary roles they created" 
ON public.library_salary_roles FOR DELETE 
USING (auth.uid() = created_by);

-- Similar policies for equipment
CREATE POLICY "Users can view all library equipment" 
ON public.library_equipment FOR SELECT USING (true);

CREATE POLICY "Users can create library equipment" 
ON public.library_equipment FOR INSERT 
WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update library equipment they created" 
ON public.library_equipment FOR UPDATE 
USING (auth.uid() = created_by);

CREATE POLICY "Users can delete library equipment they created" 
ON public.library_equipment FOR DELETE 
USING (auth.uid() = created_by);

-- Policy for usage tracking
CREATE POLICY "Users can manage library usage for accessible models" 
ON public.library_object_usage FOR ALL 
USING (EXISTS (
  SELECT 1 FROM models m 
  JOIN projects p ON m.project_id = p.id 
  WHERE m.id = library_object_usage.model_id 
  AND p.created_by = auth.uid()
));

-- Create triggers for updated_at
CREATE TRIGGER update_library_schedules_updated_at
BEFORE UPDATE ON public.library_schedules
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_library_direct_roles_updated_at
BEFORE UPDATE ON public.library_direct_roles
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_library_salary_roles_updated_at
BEFORE UPDATE ON public.library_salary_roles
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_library_equipment_updated_at
BEFORE UPDATE ON public.library_equipment
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_library_object_usage_updated_at
BEFORE UPDATE ON public.library_object_usage
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Create indexes for performance
CREATE INDEX idx_library_schedules_code ON library_schedules(schedule_code);
CREATE INDEX idx_library_direct_roles_code ON library_direct_roles(role_code);
CREATE INDEX idx_library_salary_roles_code ON library_salary_roles(role_code);
CREATE INDEX idx_library_equipment_code ON library_equipment(equipment_code);
CREATE INDEX idx_library_usage_model_id ON library_object_usage(model_id);
CREATE INDEX idx_library_usage_object ON library_object_usage(library_object_id, library_object_type);