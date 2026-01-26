-- Add system settings for library field visibility
INSERT INTO public.system_settings (setting_key, setting_value, category, description, data_type, is_public)
VALUES 
  (
    'library_schedules_visible_fields',
    '["name", "schedule_code", "description", "days_per_week", "hours_per_day", "shifts_per_day"]'::jsonb,
    'library',
    'Controls which fields are visible when creating/editing schedule library objects',
    'json',
    false
  ),
  (
    'library_direct_roles_visible_fields',
    '["role_name", "role_code", "role_category", "country", "base_hourly_rate", "currency"]'::jsonb,
    'library',
    'Controls which fields are visible when creating/editing direct role library objects',
    'json',
    false
  ),
  (
    'library_salary_roles_visible_fields',
    '["role_name", "role_code", "role_category", "country", "annual_salary", "currency"]'::jsonb,
    'library',
    'Controls which fields are visible when creating/editing salary role library objects',
    'json',
    false
  ),
  (
    'library_equipment_visible_fields',
    '["equipment_name", "equipment_code", "category", "manufacturer", "purchase_price"]'::jsonb,
    'library',
    'Controls which fields are visible when creating/editing equipment library objects',
    'json',
    false
  );