-- Delete duplicate cost allocations from source model
-- These are the 6 duplicate records identified in the source model
DELETE FROM cost_price_allocations
WHERE id IN (
  '2742f211-f538-493e-ba3b-6017546d0b3d',
  'a562e5f4-2728-4947-b1a6-8029c8dc7354',
  '8813b8b1-590c-4208-96cf-1aa0bb2f975d',
  '0899a3e1-2d5c-430d-ab4d-d83b77e83b16',
  'de030cdf-f4ff-4047-9426-8c2c263dfe9a',
  'efa2abfd-8b2a-4641-89be-bc65bc2d010a'
);