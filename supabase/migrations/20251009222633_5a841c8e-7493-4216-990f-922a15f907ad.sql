-- Equipment Refactoring: Simplified Structure
-- Drop old tables and create new structure

-- Drop existing tables
DROP TABLE IF EXISTS public.equipment CASCADE;
DROP TABLE IF EXISTS public.library_equipment CASCADE;

-- Create new library_equipment table
CREATE TABLE public.library_equipment (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  equipment_name VARCHAR(255) NOT NULL,
  description TEXT,
  year INTEGER,
  currency_code VARCHAR(3) DEFAULT 'USD',
  inflation_rate NUMERIC(5,2) DEFAULT 0,
  
  -- Lease Information
  lease_cost_per_year NUMERIC(15,2),
  lease_term_years INTEGER,
  lease_maintenance_cost_per_year NUMERIC(15,2),
  
  -- Purchase Information
  purchase_cost NUMERIC(15,2),
  useful_life_years INTEGER,
  
  -- Metadata
  is_active BOOLEAN DEFAULT true,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create new equipment table (model-specific)
CREATE TABLE public.equipment (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES public.models(id) ON DELETE CASCADE,
  library_source_id UUID REFERENCES public.library_equipment(id),
  
  equipment_name VARCHAR(255) NOT NULL,
  description TEXT,
  year INTEGER,
  currency_code VARCHAR(3) DEFAULT 'USD',
  inflation_rate NUMERIC(5,2) DEFAULT 0,
  
  -- Lease Information
  lease_cost_per_year NUMERIC(15,2),
  lease_term_years INTEGER,
  lease_maintenance_cost_per_year NUMERIC(15,2),
  
  -- Purchase Information
  purchase_cost NUMERIC(15,2),
  useful_life_years INTEGER,
  
  quantity NUMERIC(15,2) DEFAULT 1,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.library_equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.equipment ENABLE ROW LEVEL SECURITY;

-- RLS Policies for library_equipment
CREATE POLICY "Users can view library equipment with permission"
ON public.library_equipment FOR SELECT
TO authenticated
USING (has_permission(auth.uid(), 'library.view'::permission_type));

CREATE POLICY "Users can create library equipment"
ON public.library_equipment FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update library equipment they created"
ON public.library_equipment FOR UPDATE
TO authenticated
USING (auth.uid() = created_by);

CREATE POLICY "Users can delete library equipment they created"
ON public.library_equipment FOR DELETE
TO authenticated
USING (auth.uid() = created_by);

-- RLS Policies for equipment (model-specific)
CREATE POLICY "Users can view equipment for accessible models"
ON public.equipment FOR SELECT
TO authenticated
USING (EXISTS (
  SELECT 1 FROM models m
  WHERE m.id = equipment.model_id 
  AND can_access_project(auth.uid(), m.project_id)
));

CREATE POLICY "Users can edit equipment for accessible models"
ON public.equipment FOR ALL
TO authenticated
USING (EXISTS (
  SELECT 1 FROM models m
  WHERE m.id = equipment.model_id 
  AND can_edit_project(auth.uid(), m.project_id)
));

-- Triggers
CREATE TRIGGER update_library_equipment_updated_at
BEFORE UPDATE ON public.library_equipment
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_equipment_updated_at
BEFORE UPDATE ON public.equipment
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Indexes
CREATE INDEX idx_library_equipment_name ON library_equipment(equipment_name);
CREATE INDEX idx_library_equipment_active ON library_equipment(is_active);
CREATE INDEX idx_equipment_model_id ON equipment(model_id);
CREATE INDEX idx_equipment_library_source ON equipment(library_source_id);