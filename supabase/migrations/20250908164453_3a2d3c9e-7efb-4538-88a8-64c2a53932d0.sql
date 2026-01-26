-- Create demo data for Library Salary Roles and Equipment
-- Using existing user ID for created_by field

-- Library Salary Roles (18 roles)
INSERT INTO public.library_salary_roles (
  role_name, role_code, role_category, description, country, state, city, currency,
  annual_salary, allocation_method, department, grade_level, cost_center,
  bonus_target_percentage, benefits_percentage, overhead_percentage,
  minimum_experience, direct_reports, required_education, required_certifications,
  is_active, created_by
) VALUES
-- Executive Management
('Plant Manager', 'PM-US', 'Management', 'Overall plant operations manager responsible for P&L', 'United States', 'Ohio', 'Columbus', 'USD', 125000, 'Direct', 'Operations', 'Executive', 'OP-001', 20.0, 35.0, 15.0, 10, 8, 'Bachelor''s Degree in Engineering or Business', ARRAY['MBA Preferred', 'Lean Six Sigma Black Belt'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Operations Manager', 'OM-US', 'Management', 'Operations manager overseeing production activities', 'United States', 'Michigan', 'Detroit', 'USD', 95000, 'Direct', 'Operations', 'Senior Management', 'OP-001', 15.0, 32.0, 12.0, 8, 6, 'Bachelor''s Degree in Engineering', ARRAY['PMP Certification', 'Lean Manufacturing'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Quality Manager', 'QM-US', 'Management', 'Quality assurance manager ensuring compliance and standards', 'United States', 'Indiana', 'Indianapolis', 'USD', 88000, 'Direct', 'Quality', 'Management', 'QA-001', 12.0, 30.0, 10.0, 7, 4, 'Bachelor''s Degree in Engineering or Science', ARRAY['ASQ CQM', 'ISO 9001 Lead Auditor'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Maintenance Manager', 'MM-US', 'Management', 'Maintenance department manager for reliability and uptime', 'United States', 'Texas', 'Houston', 'USD', 92000, 'Indirect', 'Maintenance', 'Management', 'MT-001', 15.0, 32.0, 12.0, 8, 5, 'Bachelor''s Degree in Engineering', ARRAY['CMRP Certification', 'Reliability Engineering'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- Engineering Roles
('Senior Process Engineer', 'SPE-US', 'Technical', 'Senior process engineer for manufacturing optimization', 'United States', 'California', 'San Jose', 'USD', 105000, 'Direct', 'Engineering', 'Senior Professional', 'EN-001', 15.0, 28.0, 8.0, 8, 2, 'Bachelor''s Degree in Chemical/Mechanical Engineering', ARRAY['PE License', 'Six Sigma Black Belt'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Project Manager', 'PJM-US', 'Technical', 'Project manager for capital and improvement projects', 'United States', 'Illinois', 'Chicago', 'USD', 98000, 'Mixed', 'Engineering', 'Senior Professional', 'EN-001', 12.0, 30.0, 10.0, 6, 3, 'Bachelor''s Degree in Engineering or Business', ARRAY['PMP Certification', 'Project Management'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Design Engineer', 'DE-US', 'Technical', 'Design engineer for product and process development', 'United States', 'Pennsylvania', 'Pittsburgh', 'USD', 82000, 'Direct', 'Engineering', 'Professional', 'EN-001', 10.0, 28.0, 8.0, 4, 1, 'Bachelor''s Degree in Mechanical Engineering', ARRAY['CAD Certification', 'SolidWorks Professional'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Quality Engineer', 'QE-US', 'Technical', 'Quality engineer for process improvement and compliance', 'United States', 'Georgia', 'Atlanta', 'USD', 78000, 'Direct', 'Quality', 'Professional', 'QA-001', 10.0, 28.0, 8.0, 3, 0, 'Bachelor''s Degree in Engineering', ARRAY['Six Sigma Green Belt', 'Statistical Analysis'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- Administration and Support
('HR Manager', 'HRM-US', 'Administration', 'Human resources manager for employee relations and compliance', 'United States', 'Florida', 'Tampa', 'USD', 85000, 'Indirect', 'Human Resources', 'Management', 'HR-001', 12.0, 32.0, 18.0, 6, 3, 'Bachelor''s Degree in HR or Business', ARRAY['SHRM-CP', 'Employment Law'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Finance Manager', 'FM-US', 'Administration', 'Finance manager for budgeting and financial reporting', 'United States', 'North Carolina', 'Charlotte', 'USD', 92000, 'Indirect', 'Finance', 'Management', 'FN-001', 15.0, 30.0, 15.0, 7, 2, 'Bachelor''s Degree in Finance or Accounting', ARRAY['CPA', 'Financial Analysis'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('IT Manager', 'ITM-US', 'Administration', 'IT manager for systems and infrastructure management', 'United States', 'Arizona', 'Phoenix', 'USD', 96000, 'Indirect', 'Information Technology', 'Management', 'IT-001', 15.0, 30.0, 12.0, 8, 4, 'Bachelor''s Degree in Computer Science or IT', ARRAY['CISSP', 'Cloud Certifications'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- Professional Staff
('Business Analyst', 'BA-US', 'Administration', 'Business analyst for process improvement and data analysis', 'United States', 'Washington', 'Seattle', 'USD', 72000, 'Indirect', 'Operations', 'Professional', 'OP-002', 8.0, 28.0, 10.0, 3, 0, 'Bachelor''s Degree in Business or Engineering', ARRAY['Business Analysis', 'Data Analytics'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Financial Analyst', 'FA-US', 'Administration', 'Financial analyst for budgeting and cost analysis', 'United States', 'Nevada', 'Las Vegas', 'USD', 68000, 'Indirect', 'Finance', 'Professional', 'FN-001', 8.0, 28.0, 10.0, 2, 0, 'Bachelor''s Degree in Finance or Accounting', ARRAY['Financial Modeling', 'Excel Advanced'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Training Coordinator', 'TC-US', 'Administration', 'Training coordinator for employee development programs', 'United States', 'Oregon', 'Portland', 'USD', 58000, 'Indirect', 'Human Resources', 'Professional', 'HR-001', 8.0, 30.0, 15.0, 3, 0, 'Bachelor''s Degree in Education or HR', ARRAY['Training Development', 'Adult Learning'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- International Roles
('Operations Manager', 'OM-CA', 'Management', 'Operations manager for Canadian facility', 'Canada', 'Ontario', 'Toronto', 'CAD', 115000, 'Direct', 'Operations', 'Management', 'OP-001', 15.0, 35.0, 12.0, 8, 5, 'Bachelor''s Degree in Engineering', ARRAY['PMP Certification'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Gerente de Operaciones', 'GO-MX', 'Management', 'Operations manager for Mexican manufacturing plant', 'Mexico', 'Nuevo León', 'Monterrey', 'MXN', 1850000, 'Direct', 'Operaciones', 'Gerencia', 'OP-001', 20.0, 42.0, 15.0, 8, 6, 'Licenciatura en Ingeniería', ARRAY['Lean Manufacturing', 'Six Sigma'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Betriebsleiter', 'BL-DE', 'Management', 'Operations manager for German manufacturing facility', 'Germany', 'Bavaria', 'Munich', 'EUR', 95000, 'Direct', 'Betrieb', 'Management', 'OP-001', 18.0, 45.0, 20.0, 8, 5, 'Diplom-Ingenieur oder Master', ARRAY['Lean Production', 'ISO 9001'], true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Operations Manager', 'OM-UK', 'Management', 'Operations manager for UK manufacturing site', 'United Kingdom', 'England', 'Birmingham', 'GBP', 75000, 'Direct', 'Operations', 'Management', 'OP-001', 15.0, 38.0, 15.0, 7, 4, 'Bachelor''s Degree in Engineering', ARRAY['Chartered Engineer'], true, '43d473ce-8e9c-481b-8614-b96c439361c0');

-- Library Equipment (28 pieces)
INSERT INTO public.library_equipment (
  equipment_name, equipment_code, category, description, manufacturer, model_number,
  purchase_price, lease_monthly_rate, useful_life_years, depreciation_method,
  capacity, capacity_unit, power_requirement, space_required_sqft,
  maintenance_annual, insurance_annual, salvage_value,
  operator_required, requires_certification, certification_type,
  availability_percentage, lead_time_days, fuel_cost_per_hour,
  length, width, height, weight, discontinued, is_active, created_by
) VALUES
-- Production Equipment
('CNC Machining Center', 'CNC-MC-5000', 'Production', '5-axis CNC machining center for precision manufacturing', 'Haas Automation', 'VF-5/50', 285000, 4750, 15, 'Straight', 50, 'Workpieces/Day', '480V 3-Phase 60Hz', 400, 15000, 2850, 28500, true, true, 'CNC Operation Level 3', 92, 180, NULL, 144, 96, 108, 18500, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Automated Assembly Line', 'AAL-2500', 'Production', 'Fully automated assembly line with robotic stations', 'ABB Robotics', 'FlexLine 2500', 850000, 14500, 20, 'Straight', 2500, 'Units/Day', '480V 3-Phase 50Hz', 2500, 45000, 8500, 85000, false, true, 'Robotics Programming', 95, 360, NULL, 300, 48, 96, 125000, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Injection Molding Machine', 'IMM-350T', 'Production', '350-ton plastic injection molding machine', 'Engel', 'Victory 3550/350', 425000, 7200, 18, 'Straight', 350, 'Tons Clamping', '480V 3-Phase 60Hz', 800, 22000, 4250, 42500, true, true, 'Injection Molding Certification', 88, 240, NULL, 216, 96, 120, 45000, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Conveyor System', 'CONV-200', 'Production', '200-foot modular conveyor system for material transport', 'Dorner', 'FlexMove 200', 85000, 1450, 12, 'Straight', 200, 'Feet Length', '240V Single Phase', 150, 4500, 850, 8500, false, false, NULL, 98, 90, NULL, 2400, 24, 36, 8500, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- Material Handling Equipment
('Forklift - Electric', 'FL-E5000', 'Material Handling', '5000 lb capacity electric forklift for warehouse operations', 'Toyota', '8FBRE25', 45000, 780, 10, 'Straight', 5000, 'Pounds', '48V Electric', 80, 3500, 450, 4500, true, true, 'Forklift Certification', 90, 45, NULL, 96, 48, 83, 9500, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Overhead Crane', 'OHC-10T', 'Material Handling', '10-ton overhead bridge crane for heavy lifting', 'Konecranes', 'CXT 10-ton', 185000, 3200, 25, 'Straight', 10, 'Tons', '480V 3-Phase 60Hz', 500, 12000, 1850, 18500, true, true, 'Crane Operator Certification', 95, 180, NULL, 600, 120, 180, 35000, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('AGV System', 'AGV-5UNIT', 'Material Handling', 'Automated guided vehicle system with 5 units', 'Seegrid', 'Vision Guided Palletized Truck', 275000, 4800, 12, 'Straight', 4000, 'Pounds per Unit', '48V Electric', 200, 18000, 2750, 27500, false, true, 'AGV Programming', 93, 120, NULL, 84, 36, 72, 2500, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Pallet Jack - Electric', 'PJ-E3000', 'Material Handling', '3000 lb electric pallet jack for material transport', 'Crown Equipment', 'PE 3000', 8500, 150, 8, 'Straight', 3000, 'Pounds', '24V Electric', 25, 850, 85, 850, true, false, NULL, 88, 30, NULL, 60, 27, 50, 850, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- IT Equipment
('Industrial Server', 'SRV-DELL-R750', 'IT Equipment', 'Dell PowerEdge R750 server for manufacturing systems', 'Dell Technologies', 'PowerEdge R750', 15500, 280, 5, 'Accelerated', 256, 'GB RAM', '120V Single Phase', 12, 1500, 155, 1550, false, false, NULL, 99, 21, NULL, 25, 17, 3, 45, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Network Switch', 'SW-CISCO-48P', 'IT Equipment', '48-port Cisco managed network switch for plant network', 'Cisco Systems', 'Catalyst 2960-X', 3200, 60, 7, 'Straight', 48, 'Ports', '120V Single Phase', 4, 320, 32, 320, false, true, 'Network Administration', 99.9, 14, NULL, 17, 11, 2, 8, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Industrial Workstation', 'WS-HP-Z4', 'IT Equipment', 'HP Z4 G4 workstation for CAD and engineering applications', 'HP Inc.', 'Z4 G4 Workstation', 4800, 85, 5, 'Accelerated', 64, 'GB RAM', '120V Single Phase', 8, 480, 48, 480, false, false, NULL, 95, 7, NULL, 17, 7, 15, 35, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Wireless Access Point', 'WAP-UBNT-U6', 'IT Equipment', 'UniFi 6 Enterprise wireless access point for factory WiFi', 'Ubiquiti Networks', 'U6-Enterprise', 380, 8, 5, 'Straight', 300, 'Concurrent Users', '48V PoE', 2, 38, 4, 38, false, true, 'Network Configuration', 99.5, 3, NULL, 9, 9, 2, 2, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- Office Equipment
('Multifunction Printer', 'MFP-XEROX-C7000', 'Office Equipment', 'Xerox AltaLink C7000 color multifunction printer', 'Xerox Corporation', 'AltaLink C7030', 8500, 150, 7, 'Straight', 30, 'PPM Color', '120V Single Phase', 15, 850, 85, 850, false, false, NULL, 92, 14, NULL, 26, 26, 45, 180, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Conference Room System', 'CRS-POLY-STUDIO', 'Office Equipment', 'Poly Studio X70 video conferencing system', 'Poly', 'Studio X70', 6500, 115, 6, 'Straight', 20, 'Participants', '120V Single Phase', 8, 650, 65, 650, false, true, 'AV System Operation', 95, 21, NULL, 4, 35, 8, 25, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Industrial Printer', 'IP-ZEBRA-ZT600', 'Office Equipment', 'Zebra ZT600 series industrial label printer', 'Zebra Technologies', 'ZT610', 2800, 50, 8, 'Straight', 14, 'IPS Print Speed', '120V Single Phase', 4, 280, 28, 280, false, false, NULL, 90, 7, NULL, 15, 19, 12, 65, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- Vehicles
('Delivery Truck', 'TRUCK-FORD-E350', 'Vehicles', 'Ford E-350 cargo van for parts and material delivery', 'Ford Motor Company', 'E-350 Cargo Van', 42000, 720, 8, 'Straight', 4600, 'Pounds Payload', 'Gasoline V8', 80, 4200, 1260, 8400, true, true, 'Commercial Driver License', 85, 60, 12.50, 244, 79, 84, 6800, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Maintenance Van', 'VAN-CHEVY-EXPRESS', 'Vehicles', 'Chevrolet Express 2500 work van for maintenance team', 'General Motors', 'Express 2500', 38500, 650, 8, 'Straight', 3500, 'Pounds Payload', 'Gasoline V8', 75, 3850, 1155, 7700, true, false, NULL, 88, 45, 11.80, 224, 79, 84, 6200, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Pickup Truck', 'PICKUP-RAM-1500', 'Vehicles', 'Ram 1500 pickup truck for general facility use', 'Stellantis', 'Ram 1500 Big Horn', 35000, 590, 8, 'Straight', 1500, 'Pounds Payload', 'Gasoline V6', 60, 3500, 1050, 7000, true, false, NULL, 90, 30, 9.20, 228, 82, 77, 4900, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- Tools and Equipment
('Precision Measuring Set', 'PMS-MITUTOYO-500', 'Tools', 'Mitutoyo precision measuring instrument set', 'Mitutoyo Corporation', 'Digimatic Caliper Set', 1800, 35, 10, 'Straight', 12, 'Piece Set', 'Battery Powered', 2, 180, 18, 180, false, true, 'Precision Measurement', 98, 14, NULL, 12, 8, 4, 5, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Welding Station', 'WS-MILLER-252', 'Tools', 'Miller Multimatic 255 welding station with accessories', 'Miller Electric', 'Multimatic 255', 4500, 80, 12, 'Straight', 255, 'Amp Output', '240V Single Phase', 25, 450, 45, 450, true, true, 'Welding Certification', 92, 21, NULL, 36, 18, 28, 95, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Air Compressor System', 'ACS-ATLAS-GA22', 'Tools', 'Atlas Copco GA22 rotary screw air compressor', 'Atlas Copco', 'GA22VSD+', 28000, 480, 15, 'Straight', 125, 'CFM @ 125 PSI', '480V 3-Phase 60Hz', 80, 2800, 280, 2800, false, true, 'Compressed Air Systems', 95, 90, NULL, 84, 36, 60, 1250, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Tool Crib System', 'TCS-STANLEY-VIDMAR', 'Tools', 'Stanley Vidmar automated tool crib dispensing system', 'Stanley Black & Decker', 'Vidmar VR300', 45000, 780, 12, 'Straight', 300, 'Tool Locations', '120V Single Phase', 60, 4500, 450, 4500, false, true, 'Tool Management System', 96, 120, NULL, 72, 30, 84, 2200, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),

-- Safety Equipment
('Emergency Eyewash Station', 'EWS-HAWS-7500', 'Tools', 'Haws 7500 emergency eyewash and shower station', 'Haws Corporation', '7500', 3200, 58, 15, 'Straight', 2, 'Station Capacity', 'Plumbed Water', 12, 320, 32, 320, false, false, NULL, 99, 30, NULL, 36, 24, 96, 350, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('Fire Suppression System', 'FSS-ANSUL-R102', 'Tools', 'Ansul R-102 restaurant fire suppression system', 'Ansul Incorporated', 'R-102', 8500, 150, 20, 'Straight', 12, 'Nozzle Coverage', '120V Single Phase', 25, 850, 85, 850, false, true, 'Fire System Maintenance', 99.9, 60, NULL, 48, 24, 18, 85, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0'),
('First Aid Station', 'FAS-ACME-DELUXE', 'Tools', 'Acme United deluxe industrial first aid station', 'Acme United Corporation', 'PhysiciansCare 90575', 850, 18, 8, 'Straight', 150, 'Person Capacity', 'Wall Mounted', 4, 85, 9, 85, false, false, NULL, 100, 7, NULL, 24, 6, 20, 25, false, true, '43d473ce-8e9c-481b-8614-b96c439361c0');