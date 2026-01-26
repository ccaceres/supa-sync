-- Restore correct project categories data
UPDATE system_settings 
SET setting_value = jsonb_build_array(
  jsonb_build_object('name', 'New Business', 'description', 'Projects for acquiring new customers or entering new markets', 'is_active', true),
  jsonb_build_object('name', 'Existing Business', 'description', 'Projects for existing customers and operations', 'is_active', true),
  jsonb_build_object('name', 'Consultative', 'description', 'Advisory and consulting projects', 'is_active', true)
)
WHERE setting_key = 'project_categories';

-- Verify project_types data is correctly structured
UPDATE system_settings 
SET setting_value = jsonb_build_object(
  'New Business', jsonb_build_array(
    jsonb_build_object('name', 'RFP Response', 'description', 'Response to Request for Proposal', 'is_active', true),
    jsonb_build_object('name', 'Proactive Bid', 'description', 'Proactive business development opportunity', 'is_active', true),
    jsonb_build_object('name', 'Market Entry', 'description', 'Entering a new market or geography', 'is_active', true)
  ),
  'Existing Business', jsonb_build_array(
    jsonb_build_object('name', 'Renewal', 'description', 'Contract renewal for existing customer', 'is_active', true),
    jsonb_build_object('name', 'Expansion', 'description', 'Expanding services for existing customer', 'is_active', true),
    jsonb_build_object('name', 'Optimization', 'description', 'Optimizing existing operations', 'is_active', true)
  ),
  'Consultative', jsonb_build_array(
    jsonb_build_object('name', 'Advisory', 'description', 'Advisory services', 'is_active', true),
    jsonb_build_object('name', 'Assessment', 'description', 'Assessment and evaluation', 'is_active', true)
  )
)
WHERE setting_key = 'project_types';