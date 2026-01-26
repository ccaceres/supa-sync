-- Remove duplicate formulas (keep only the newer versions created at 06:35:48)
DELETE FROM formula_definitions 
WHERE id IN (
  'c6c44cd2-f79f-4b1c-9073-beba58c98d80',
  'c17f5ff6-2ef1-498c-8c1e-0be969f3f586',
  '984be31f-063d-49d1-b23a-4c3692bea3cf',
  '4e445387-0795-4dc5-a48f-5267adcfc160',
  'e12431de-e0dd-4d40-afd1-e10b9c46655a'
);