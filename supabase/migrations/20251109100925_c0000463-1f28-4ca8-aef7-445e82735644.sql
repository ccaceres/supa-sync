-- Fix equipment cost formulas: remove incorrect equipment_quantity dependency
-- These formulas should use Quantity directly from calculatedValues, not evaluate equipment_quantity

UPDATE formula_definitions 
SET depends_on = ARRAY[]::text[],
    updated_at = NOW()
WHERE formula_key IN ('equipment_lease_cost', 'equipment_purchase_cost')
AND is_active = true
AND 'equipment_quantity' = ANY(depends_on);