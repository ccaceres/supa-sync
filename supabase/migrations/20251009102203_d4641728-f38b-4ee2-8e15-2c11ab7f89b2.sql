-- Update the default visible fields to include all fields
UPDATE system_settings 
SET setting_value = '["round_number", "name", "status", "type", "description", "kickoff_date", "information_exchange_date", "submission_date", "solutions_go_date", "pipeline_id", "approver_designations"]'
WHERE setting_key = 'round_visible_fields';