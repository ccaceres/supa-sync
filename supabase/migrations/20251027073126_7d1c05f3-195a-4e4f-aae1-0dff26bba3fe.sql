-- Update all model formulas to match their library template's category
UPDATE formula_definitions fd
SET category = ft.category,
    updated_at = now()
FROM formula_templates ft
WHERE fd.library_formula_id = ft.id
  AND (fd.category != ft.category OR fd.category IS NULL);