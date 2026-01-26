-- Add UI visibility control column to profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS show_admin_ui boolean DEFAULT false;

-- Set default true for the three core admins
UPDATE public.profiles 
SET show_admin_ui = true 
WHERE full_name ILIKE '%andrew%' 
   OR full_name ILIKE '%carlos%' 
   OR full_name ILIKE '%ignacio%';

-- Add comment for documentation
COMMENT ON COLUMN public.profiles.show_admin_ui IS 
  'Controls UI visibility of admin features. Independent of actual role permissions.';