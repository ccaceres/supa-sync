-- Remove library_dl_roles concept and clean up references

-- Step 1: Remove foreign key column from dl_roles table
ALTER TABLE dl_roles DROP COLUMN IF EXISTS library_dl_role_id;

-- Step 2: Drop the library_dl_roles table completely
DROP TABLE IF EXISTS library_dl_roles CASCADE;

-- Step 3: Ensure dl_roles has all required fields (they already exist, just confirming)
-- nonexempt_position_id, schedule_id, shift_1_percentage, shift_2_percentage, shift_3_percentage
-- temp_percentage, annual_inflation_percentage are already present

-- Step 4: Add comments to clarify the DL Role concept
COMMENT ON TABLE dl_roles IS 'LABEX Tasks - DL Role is the combination of position, schedule, shift split, temp%, and inflation% configured per task';
COMMENT ON COLUMN dl_roles.nonexempt_position_id IS 'DL Position from library - part of DL Role configuration';
COMMENT ON COLUMN dl_roles.schedule_id IS 'Schedule from library - part of DL Role configuration';
COMMENT ON COLUMN dl_roles.shift_1_percentage IS 'Shift 1% - part of DL Role configuration, must total 100% with shift_2 and shift_3';
COMMENT ON COLUMN dl_roles.shift_2_percentage IS 'Shift 2% - part of DL Role configuration';
COMMENT ON COLUMN dl_roles.shift_3_percentage IS 'Shift 3% - part of DL Role configuration';
COMMENT ON COLUMN dl_roles.temp_percentage IS 'Temporary workers % - part of DL Role configuration';
COMMENT ON COLUMN dl_roles.annual_inflation_percentage IS 'Annual wage inflation % - part of DL Role configuration';