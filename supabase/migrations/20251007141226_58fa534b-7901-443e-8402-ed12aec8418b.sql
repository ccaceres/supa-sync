-- Make field visibility settings public so all authenticated users can read them
-- Only admins can still modify these settings (controlled by RPC function security)

UPDATE public.system_settings 
SET is_public = true 
WHERE setting_key IN (
  'project_visible_fields',
  'library_salary_roles_visible_fields',
  'library_direct_roles_visible_fields',
  'library_equipment_visible_fields',
  'library_schedules_visible_fields'
);
