-- Restore missing AWDpHC formula with correct category
-- First check if it exists
DO $$
BEGIN
  -- Update if exists, otherwise insert
  IF EXISTS (SELECT 1 FROM formula_templates WHERE formula_key = 'AWDpHC') THEN
    UPDATE formula_templates 
    SET 
      category = 'cost',
      expression = '(PDpY - (PHOpY + PPTODOpY + PADOpY)) * (1 - Temp_Pct / 100) + (OD * Temp_Pct / 100)',
      display_name = 'Annual Working Days per HC (AWDpHC)',
      description = 'Calculates annual working days per headcount, accounting for holidays, PTO, additional days off, and temporary labor percentage',
      result_type = 'number',
      result_unit = 'days',
      decimal_places = 2,
      updated_at = NOW()
    WHERE formula_key = 'AWDpHC';
  ELSE
    INSERT INTO formula_templates (
      template_name,
      display_name,
      formula_key,
      category,
      expression,
      description,
      result_type,
      result_unit,
      decimal_places,
      is_system,
      version
    ) VALUES (
      'productivity',
      'Annual Working Days per HC (AWDpHC)',
      'AWDpHC',
      'cost',
      '(PDpY - (PHOpY + PPTODOpY + PADOpY)) * (1 - Temp_Pct / 100) + (OD * Temp_Pct / 100)',
      'Calculates annual working days per headcount, accounting for holidays, PTO, additional days off, and temporary labor percentage',
      'number',
      'days',
      2,
      true,
      1
    );
  END IF;
END $$;