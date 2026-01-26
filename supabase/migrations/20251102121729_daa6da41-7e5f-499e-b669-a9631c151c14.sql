-- Fix equipment quantity formula to use set-specific headcount
UPDATE formula_definitions
SET 
  expression = 'ROUNDUP(MaxOperatingHeadcountForEquipmentSet * (EquipmentFactor / 100), 0)',
  updated_at = now()
WHERE formula_key = 'equipment_quantity';