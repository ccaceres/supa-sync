-- Fix broken foreign key references in cost_price_allocations
-- These 5 allocations were referencing price lines from other models

-- Update Labex site allocation to correct price line
UPDATE cost_price_allocations
SET price_line_id = '2c224787-6e18-49e6-bfbd-5e35c4199fdc'
WHERE id = '8ba8636b-f01f-4e2e-a4a6-d95bbe217ed0'
  AND model_id = 'e9988147-9a29-4046-abf6-3feab37f969d';

-- Update Warehouse Opex to correct price line
UPDATE cost_price_allocations
SET price_line_id = '0a958211-9103-431c-87cc-d3a2e1826e71'
WHERE id = '14b23112-6e2f-46c3-a31e-807085c15a16'
  AND model_id = 'e9988147-9a29-4046-abf6-3feab37f969d';

-- Update Janitorial to correct price line
UPDATE cost_price_allocations
SET price_line_id = '0924fe0c-6998-4c96-95f3-6bd832f1cd16'
WHERE id = 'ae38413d-02cf-4562-8a84-7512a4bf817c'
  AND model_id = 'e9988147-9a29-4046-abf6-3feab37f969d';

-- Update Opex site allocation to correct price line
UPDATE cost_price_allocations
SET price_line_id = '0924fe0c-6998-4c96-95f3-6bd832f1cd16'
WHERE id = 'e13bd991-69dd-4409-81f6-d04f7e1e2cc5'
  AND model_id = 'e9988147-9a29-4046-abf6-3feab37f969d';

-- Update FTZ Security Guards to correct price line
UPDATE cost_price_allocations
SET price_line_id = '0924fe0c-6998-4c96-95f3-6bd832f1cd16'
WHERE id = '8cb314da-f33d-4d7f-980a-5ea982ecf386'
  AND model_id = 'e9988147-9a29-4046-abf6-3feab37f969d';