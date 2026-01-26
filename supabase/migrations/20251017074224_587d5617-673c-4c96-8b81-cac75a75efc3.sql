-- Add Formulas navigation item to Cost Input group (with LABEX)
INSERT INTO public.navigation_items (
  group_id,
  label,
  url,
  icon,
  display_order,
  is_visible,
  is_protected,
  url_type,
  context_required,
  required_permissions
)
SELECT 
  ng.id as group_id,
  'Formulas' as label,
  '/projects/{projectId}/rounds/{roundId}/models/{modelId}/formulas' as url,
  'Calculator' as icon,
  (SELECT COALESCE(MAX(display_order), 0) + 1 FROM public.navigation_items WHERE group_id = ng.id) as display_order,
  true as is_visible,
  false as is_protected,
  'model' as url_type,
  true as context_required,
  ARRAY['models.view']::text[] as required_permissions
FROM public.navigation_groups ng
JOIN public.navigation_config nc ON ng.config_id = nc.id
WHERE ng.label = 'Cost Input' 
  AND nc.is_active = true
  AND NOT EXISTS (
    SELECT 1 FROM public.navigation_items 
    WHERE group_id = ng.id AND label = 'Formulas'
  );