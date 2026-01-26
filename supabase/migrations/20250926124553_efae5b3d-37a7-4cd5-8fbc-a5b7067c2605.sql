-- Add system setting to control Customers menu visibility
INSERT INTO system_settings (
  setting_key, 
  setting_value, 
  category, 
  description, 
  data_type, 
  is_public
) VALUES (
  'show_customers_menu', 
  'true', 
  'ui', 
  'Show or hide the Customers menu option in navigation', 
  'boolean', 
  true
);