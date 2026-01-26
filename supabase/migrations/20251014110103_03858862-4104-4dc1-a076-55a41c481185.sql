-- Create navigation configuration tables

-- Table to store navigation configurations
CREATE TABLE public.navigation_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR NOT NULL,
  description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT false,
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Table to store navigation groups
CREATE TABLE public.navigation_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  config_id UUID NOT NULL REFERENCES public.navigation_config(id) ON DELETE CASCADE,
  label VARCHAR NOT NULL,
  icon VARCHAR,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_visible BOOLEAN NOT NULL DEFAULT true,
  is_collapsible BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Table to store navigation items
CREATE TABLE public.navigation_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES public.navigation_groups(id) ON DELETE CASCADE,
  label VARCHAR NOT NULL,
  url VARCHAR NOT NULL,
  icon VARCHAR,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_visible BOOLEAN NOT NULL DEFAULT true,
  is_protected BOOLEAN NOT NULL DEFAULT false,
  required_permissions TEXT[],
  required_roles TEXT[],
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.navigation_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.navigation_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.navigation_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies for navigation_config
CREATE POLICY "Admins can manage navigation configs"
ON public.navigation_config
FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Authenticated users can view active config"
ON public.navigation_config
FOR SELECT
USING (is_active = true OR has_role(auth.uid(), 'admin'::app_role));

-- RLS Policies for navigation_groups
CREATE POLICY "Admins can manage navigation groups"
ON public.navigation_groups
FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Authenticated users can view groups from active config"
ON public.navigation_groups
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.navigation_config
    WHERE id = navigation_groups.config_id
    AND is_active = true
  ) OR has_role(auth.uid(), 'admin'::app_role)
);

-- RLS Policies for navigation_items
CREATE POLICY "Admins can manage navigation items"
ON public.navigation_items
FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Authenticated users can view items from active config"
ON public.navigation_items
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.navigation_groups ng
    JOIN public.navigation_config nc ON ng.config_id = nc.id
    WHERE ng.id = navigation_items.group_id
    AND nc.is_active = true
  ) OR has_role(auth.uid(), 'admin'::app_role)
);

-- Function to activate a navigation config
CREATE OR REPLACE FUNCTION public.activate_navigation_config(p_config_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Check if user is admin
  IF NOT has_role(auth.uid(), 'admin'::app_role) THEN
    RAISE EXCEPTION 'Only admins can activate navigation configs';
  END IF;
  
  -- Deactivate all other configs
  UPDATE public.navigation_config SET is_active = false WHERE is_active = true;
  
  -- Activate the selected config
  UPDATE public.navigation_config SET is_active = true, updated_at = NOW()
  WHERE id = p_config_id;
  
  RETURN FOUND;
END;
$$;

-- Function to clone a navigation config
CREATE OR REPLACE FUNCTION public.clone_navigation_config(p_config_id UUID, p_new_name VARCHAR)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_new_config_id UUID;
  v_group_record RECORD;
  v_new_group_id UUID;
  v_item_record RECORD;
BEGIN
  -- Check if user is admin
  IF NOT has_role(auth.uid(), 'admin'::app_role) THEN
    RAISE EXCEPTION 'Only admins can clone navigation configs';
  END IF;
  
  -- Create new config
  INSERT INTO public.navigation_config (name, description, created_by)
  SELECT p_new_name, description, auth.uid()
  FROM public.navigation_config
  WHERE id = p_config_id
  RETURNING id INTO v_new_config_id;
  
  -- Clone groups
  FOR v_group_record IN 
    SELECT * FROM public.navigation_groups WHERE config_id = p_config_id ORDER BY display_order
  LOOP
    INSERT INTO public.navigation_groups (config_id, label, icon, display_order, is_visible, is_collapsible)
    VALUES (v_new_config_id, v_group_record.label, v_group_record.icon, v_group_record.display_order, 
            v_group_record.is_visible, v_group_record.is_collapsible)
    RETURNING id INTO v_new_group_id;
    
    -- Clone items for this group
    FOR v_item_record IN
      SELECT * FROM public.navigation_items WHERE group_id = v_group_record.id ORDER BY display_order
    LOOP
      INSERT INTO public.navigation_items (
        group_id, label, url, icon, display_order, is_visible, is_protected,
        required_permissions, required_roles, metadata
      )
      VALUES (
        v_new_group_id, v_item_record.label, v_item_record.url, v_item_record.icon,
        v_item_record.display_order, v_item_record.is_visible, v_item_record.is_protected,
        v_item_record.required_permissions, v_item_record.required_roles, v_item_record.metadata
      );
    END LOOP;
  END LOOP;
  
  RETURN v_new_config_id;
END;
$$;

-- Triggers to update updated_at
CREATE TRIGGER update_navigation_config_updated_at
BEFORE UPDATE ON public.navigation_config
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_navigation_groups_updated_at
BEFORE UPDATE ON public.navigation_groups
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_navigation_items_updated_at
BEFORE UPDATE ON public.navigation_items
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();