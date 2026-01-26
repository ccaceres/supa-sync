-- Create demo data for Object Library
-- Using existing user ID for created_by field

-- Library Schedules (12 schedules)
INSERT INTO public.library_schedules (
  name, schedule_code, description, days_per_week, hours_per_day, shifts_per_day,
  shift_1_start, shift_1_end, shift_2_start, shift_2_end, shift_3_start, shift_3_end,
  monday, tuesday, wednesday, thursday, friday, saturday, sunday,
  overtime_threshold, overtime_multiplier, is_active, created_by
) VALUES
-- Standard Business Schedules
('Standard Business Hours', 'STD-BUS', 'Regular 8-hour business day, Monday through Friday', 5, 8, 1, '08:00:00', '16:00:00', NULL, NULL, NULL, NULL, true, true, true, true, true, false, false, 40, 1.5, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Extended Business Hours', 'EXT-BUS', 'Extended business hours for customer service', 6, 9, 1, '07:00:00', '16:00:00', NULL, NULL, NULL, NULL, true, true, true, true, true, true, false, 45, 1.5, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('European Standard', 'EUR-STD', 'European standard working hours with longer lunch break', 5, 8, 1, '09:00:00', '17:00:00', NULL, NULL, NULL, NULL, true, true, true, true, true, false, false, 40, 1.5, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- Manufacturing Schedules
('3-Shift Continental', '3SH-CONT', 'Continuous 24/7 manufacturing operation with 3 shifts', 7, 8, 3, '06:00:00', '14:00:00', '14:00:00', '22:00:00', '22:00:00', '06:00:00', true, true, true, true, true, true, true, 40, 1.5, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('2-Shift Manufacturing', '2SH-MFG', 'Two-shift manufacturing operation, Monday to Friday', 5, 8, 2, '06:00:00', '14:00:00', '14:00:00', '22:00:00', NULL, NULL, true, true, true, true, true, false, false, 40, 1.5, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Weekend Manufacturing', 'WKD-MFG', 'Weekend-only manufacturing for special projects', 2, 10, 2, '07:00:00', '17:00:00', '17:00:00', '03:00:00', NULL, NULL, false, false, false, false, false, true, true, 40, 1.5, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- Maintenance Schedules
('Maintenance Coverage', 'MAINT-24', '24/7 maintenance coverage with rotating shifts', 7, 8, 3, '08:00:00', '16:00:00', '16:00:00', '00:00:00', '00:00:00', '08:00:00', true, true, true, true, true, true, true, 40, 1.5, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Planned Maintenance', 'MAINT-PM', 'Scheduled maintenance during production downtime', 6, 10, 1, '18:00:00', '04:00:00', NULL, NULL, NULL, NULL, true, true, true, true, true, true, false, 50, 1.5, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- Specialized Schedules
('4-Day Work Week', '4DAY-WK', 'Compressed 4-day work week with longer days', 4, 10, 1, '07:00:00', '17:00:00', NULL, NULL, NULL, NULL, true, true, true, true, false, false, false, 40, 1.5, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Flexible Hours', 'FLEX-HR', 'Flexible working hours for knowledge workers', 5, 8, 1, '09:00:00', '17:00:00', NULL, NULL, NULL, NULL, true, true, true, true, true, false, false, 40, 1.5, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Security Coverage', 'SEC-24', '24/7 security coverage with 12-hour shifts', 7, 12, 2, '06:00:00', '18:00:00', '18:00:00', '06:00:00', NULL, NULL, true, true, true, true, true, true, true, 40, 1.5, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Part-Time Schedule', 'PT-20', 'Part-time schedule for temporary or seasonal workers', 5, 4, 1, '12:00:00', '16:00:00', NULL, NULL, NULL, NULL, true, true, true, true, true, false, false, 20, 1.5, true, '43d473ce-8e9c-481b-8614-b96c439361c0');

-- Library Direct Roles (24 roles)
INSERT INTO public.library_direct_roles (
  role_name, role_code, role_category, description, country, state, city, currency,
  base_hourly_rate, shift_2_adder, shift_3_adder, weekend_adder, fringe_percentage, overtime_fringe_percentage,
  cost_to_hire, training_hours, efficiency_factor, utilization_target, required_skills, required_certifications,
  is_active, effective_date, created_by
) VALUES
-- Operations Roles - USA
('Machine Operator I', 'MOP-I-US', 'Operations', 'Entry-level machine operator for automated equipment', 'United States', 'Ohio', 'Columbus', 'USD', 18.50, 1.00, 1.50, 2.00, 28.5, 32.0, 2500, 40, 0.85, 2080, ARRAY['Basic Math', 'Safety Protocols', 'Equipment Operation'], ARRAY['OSHA 10'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Machine Operator II', 'MOP-II-US', 'Operations', 'Experienced machine operator with setup capabilities', 'United States', 'Ohio', 'Columbus', 'USD', 22.75, 1.00, 1.50, 2.00, 28.5, 32.0, 3000, 80, 0.90, 2080, ARRAY['Advanced Equipment Operation', 'Quality Control', 'Troubleshooting'], ARRAY['OSHA 10', 'Forklift Certification'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Line Supervisor', 'SUP-LINE-US', 'Operations', 'Production line supervisor responsible for team leadership', 'United States', 'Michigan', 'Detroit', 'USD', 28.50, 1.25, 2.00, 2.50, 32.0, 35.0, 4500, 120, 0.95, 2080, ARRAY['Leadership', 'Production Planning', 'Problem Solving', 'Communication'], ARRAY['Supervisor Certification', 'OSHA 30'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Quality Inspector', 'QI-US', 'Operations', 'Quality control inspector for manufacturing processes', 'United States', 'Indiana', 'Indianapolis', 'USD', 24.25, 0.75, 1.25, 1.75, 30.0, 33.0, 3500, 60, 0.92, 2080, ARRAY['Quality Systems', 'Statistical Analysis', 'Measurement Tools'], ARRAY['ASQ CQI', 'ISO 9001'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- Maintenance Roles - USA
('Maintenance Mechanic', 'MECH-US', 'Maintenance', 'General maintenance mechanic for industrial equipment', 'United States', 'Texas', 'Houston', 'USD', 26.80, 1.50, 2.25, 2.75, 35.0, 38.0, 4000, 160, 0.88, 2080, ARRAY['Mechanical Repair', 'Hydraulics', 'Pneumatics', 'Welding'], ARRAY['Millwright Certification', 'AWS Welding'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Electrician', 'ELEC-US', 'Maintenance', 'Industrial electrician for plant electrical systems', 'United States', 'Pennsylvania', 'Pittsburgh', 'USD', 32.40, 2.00, 3.00, 3.50, 38.0, 42.0, 5000, 200, 0.90, 2080, ARRAY['Electrical Systems', 'PLC Programming', 'Motor Control', 'Troubleshooting'], ARRAY['Journeyman Electrician', 'NFPA 70E'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),
('HVAC Technician', 'HVAC-US', 'Maintenance', 'HVAC systems maintenance and repair technician', 'United States', 'Florida', 'Tampa', 'USD', 24.60, 1.25, 2.00, 2.25, 32.0, 35.0, 3800, 120, 0.87, 2080, ARRAY['HVAC Systems', 'Refrigeration', 'Controls', 'EPA Regulations'], ARRAY['EPA 608', 'HVAC Excellence'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- Technical Roles - USA
('Process Engineer', 'PE-US', 'Technical', 'Process engineer for manufacturing optimization', 'United States', 'California', 'San Jose', 'USD', 42.30, 0.50, 1.00, 1.50, 25.0, 28.0, 8000, 80, 0.95, 2080, ARRAY['Process Optimization', 'Statistical Analysis', 'Project Management'], ARRAY['PE License', 'Six Sigma Green Belt'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Safety Coordinator', 'SAFE-US', 'Technical', 'Workplace safety coordinator and compliance officer', 'United States', 'Illinois', 'Chicago', 'USD', 29.75, 0.75, 1.25, 1.75, 30.0, 33.0, 5500, 100, 0.93, 2080, ARRAY['Safety Management', 'Compliance', 'Training', 'Risk Assessment'], ARRAY['CSP', 'OSHA 30', 'First Aid/CPR'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- Support Roles - USA
('Material Handler', 'MH-US', 'Support', 'Material handling and warehouse operations', 'United States', 'Georgia', 'Atlanta', 'USD', 16.25, 0.75, 1.25, 1.50, 26.0, 29.0, 2000, 24, 0.82, 2080, ARRAY['Warehouse Operations', 'Inventory Management', 'Forklift Operation'], ARRAY['Forklift Certification', 'OSHA 10'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Warehouse Associate', 'WA-US', 'Support', 'General warehouse associate for shipping and receiving', 'United States', 'North Carolina', 'Charlotte', 'USD', 15.75, 0.50, 1.00, 1.25, 25.0, 28.0, 1800, 16, 0.80, 2080, ARRAY['Shipping/Receiving', 'Data Entry', 'Physical Labor'], ARRAY['OSHA 10'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Security Guard', 'SEC-US', 'Support', '24/7 security guard for facility protection', 'United States', 'Arizona', 'Phoenix', 'USD', 17.50, 1.00, 1.50, 2.00, 22.0, 25.0, 1500, 40, 0.95, 2080, ARRAY['Security Procedures', 'Emergency Response', 'Report Writing'], ARRAY['Security License', 'CPR/AED'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- International Roles - Canada
('Machine Operator', 'MOP-CA', 'Operations', 'Machine operator for Canadian manufacturing facility', 'Canada', 'Ontario', 'Toronto', 'CAD', 24.50, 1.00, 1.50, 2.00, 32.0, 35.0, 3000, 40, 0.88, 2080, ARRAY['Equipment Operation', 'Safety Protocols', 'Quality Control'], ARRAY['WSIB Certification'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Maintenance Technician', 'MAINT-CA', 'Maintenance', 'Multi-skilled maintenance technician', 'Canada', 'Alberta', 'Calgary', 'CAD', 32.80, 1.50, 2.25, 2.75, 35.0, 38.0, 4200, 120, 0.90, 2080, ARRAY['Mechanical Systems', 'Electrical Systems', 'Troubleshooting'], ARRAY['Red Seal Certification'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- International Roles - Mexico
('Operador de Máquina', 'OP-MX', 'Operations', 'Machine operator for Mexican manufacturing plant', 'Mexico', 'Nuevo León', 'Monterrey', 'MXN', 185.50, 15.00, 25.00, 30.00, 35.0, 38.0, 8000, 40, 0.85, 2080, ARRAY['Operación de Equipos', 'Protocolos de Seguridad', 'Control de Calidad'], ARRAY['STPS Certification'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Técnico de Mantenimiento', 'MANT-MX', 'Maintenance', 'Maintenance technician for production equipment', 'Mexico', 'Jalisco', 'Guadalajara', 'MXN', 225.75, 20.00, 35.00, 40.00, 38.0, 42.0, 12000, 80, 0.88, 2080, ARRAY['Sistemas Mecánicos', 'Sistemas Eléctricos', 'Soldadura'], ARRAY['CONOCER Certification'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- International Roles - Europe
('Machine Operator', 'MOP-DE', 'Operations', 'Machine operator for German manufacturing facility', 'Germany', 'Bavaria', 'Munich', 'EUR', 19.80, 1.50, 2.25, 3.00, 42.0, 45.0, 3500, 60, 0.92, 1800, ARRAY['Maschinenführung', 'Qualitätssicherung', 'Sicherheitsprotokolle'], ARRAY['IHK Certification'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Maintenance Engineer', 'MENG-UK', 'Maintenance', 'Maintenance engineer for UK facility', 'United Kingdom', 'England', 'Birmingham', 'GBP', 22.50, 2.00, 3.00, 4.00, 38.0, 42.0, 4000, 100, 0.93, 1800, ARRAY['Mechanical Engineering', 'Preventive Maintenance', 'CMMS Systems'], ARRAY['IMechE Membership'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- Specialized Roles
('CNC Machinist', 'CNC-US', 'Technical', 'CNC machinist for precision manufacturing', 'United States', 'Wisconsin', 'Milwaukee', 'USD', 28.90, 1.25, 2.00, 2.50, 32.0, 35.0, 4500, 160, 0.90, 2080, ARRAY['CNC Programming', 'Blueprint Reading', 'Precision Measurement'], ARRAY['NIMS Certification'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Welder/Fabricator', 'WELD-US', 'Technical', 'Certified welder for structural and pipe welding', 'United States', 'Louisiana', 'Baton Rouge', 'USD', 26.40, 1.50, 2.25, 2.75, 33.0, 36.0, 3800, 120, 0.88, 2080, ARRAY['MIG Welding', 'TIG Welding', 'Stick Welding', 'Blueprint Reading'], ARRAY['AWS D1.1', 'API 1104'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Forklift Operator', 'FLO-US', 'Support', 'Certified forklift operator for warehouse operations', 'United States', 'Nevada', 'Las Vegas', 'USD', 18.75, 0.75, 1.25, 1.50, 28.0, 31.0, 2200, 24, 0.83, 2080, ARRAY['Forklift Operation', 'Warehouse Safety', 'Inventory Systems'], ARRAY['Forklift Certification', 'OSHA 10'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Crane Operator', 'CRANE-US', 'Support', 'Mobile crane operator for heavy lifting operations', 'United States', 'Washington', 'Seattle', 'USD', 34.60, 2.00, 3.00, 3.50, 36.0, 40.0, 6000, 200, 0.92, 2080, ARRAY['Crane Operation', 'Rigging', 'Load Calculations', 'Safety Protocols'], ARRAY['NCCCO Certification'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Environmental Technician', 'ENV-US', 'Technical', 'Environmental compliance and monitoring technician', 'United States', 'Oregon', 'Portland', 'USD', 25.30, 0.75, 1.25, 1.75, 30.0, 33.0, 4000, 80, 0.90, 2080, ARRAY['Environmental Monitoring', 'Compliance', 'Data Collection', 'Report Writing'], ARRAY['40-Hour HAZWOPER'], true, '2024-01-01', '43d473ce-8e9c-481b-8614-b96c439361c0');