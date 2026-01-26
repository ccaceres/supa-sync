-- Update IMPEX formula templates to use the 'impex' category
UPDATE formula_templates
SET category = 'impex'
WHERE formula_key IN ('impex_base_cost', 'impex_final_cost', 'impex_yearly_cost')
  AND template_name = 'zulu_standard';