-- Create function to get model currency from finance parameters
CREATE OR REPLACE FUNCTION public.get_model_currency(p_model_id UUID)
RETURNS TEXT
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
  SELECT (data->>'model_currency')::TEXT
  FROM model_parameters
  WHERE model_id = p_model_id 
    AND parameter_type = 'finance'
  LIMIT 1;
$$;

-- Create validation function to ensure currency matches model currency
CREATE OR REPLACE FUNCTION public.validate_currency_matches_model()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_model_currency TEXT;
BEGIN
  -- Get the model's currency
  v_model_currency := get_model_currency(NEW.model_id);
  
  -- Auto-set currency to model currency
  IF v_model_currency IS NOT NULL THEN
    NEW.currency := v_model_currency;
  ELSE
    -- Fallback to USD if no model currency set
    NEW.currency := COALESCE(NEW.currency, 'USD');
  END IF;
  
  RETURN NEW;
END;
$$;

-- Create validation function for equipment (uses currency_code field)
CREATE OR REPLACE FUNCTION public.validate_equipment_currency_matches_model()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_model_currency TEXT;
BEGIN
  -- Get the model's currency
  v_model_currency := get_model_currency(NEW.model_id);
  
  -- Auto-set currency to model currency
  IF v_model_currency IS NOT NULL THEN
    NEW.currency_code := v_model_currency;
  ELSE
    -- Fallback to USD if no model currency set
    NEW.currency_code := COALESCE(NEW.currency_code, 'USD');
  END IF;
  
  RETURN NEW;
END;
$$;

-- Apply triggers to OPEX lines
DROP TRIGGER IF EXISTS enforce_opex_currency ON opex_lines;
CREATE TRIGGER enforce_opex_currency
  BEFORE INSERT OR UPDATE ON opex_lines
  FOR EACH ROW
  EXECUTE FUNCTION validate_currency_matches_model();

-- Apply triggers to IMPEX lines
DROP TRIGGER IF EXISTS enforce_impex_currency ON impex_lines;
CREATE TRIGGER enforce_impex_currency
  BEFORE INSERT OR UPDATE ON impex_lines
  FOR EACH ROW
  EXECUTE FUNCTION validate_currency_matches_model();

-- Apply triggers to Equipment (for model equipment only, not library)
DROP TRIGGER IF EXISTS enforce_equipment_currency ON equipment;
CREATE TRIGGER enforce_equipment_currency
  BEFORE INSERT OR UPDATE ON equipment
  FOR EACH ROW
  WHEN (NEW.model_id IS NOT NULL)
  EXECUTE FUNCTION validate_equipment_currency_matches_model();

-- Apply triggers to Nonexempt Positions
DROP TRIGGER IF EXISTS enforce_nonexempt_currency ON nonexempt_positions;
CREATE TRIGGER enforce_nonexempt_currency
  BEFORE INSERT OR UPDATE ON nonexempt_positions
  FOR EACH ROW
  EXECUTE FUNCTION validate_currency_matches_model();

-- Apply triggers to Exempt Positions
DROP TRIGGER IF EXISTS enforce_exempt_currency ON exempt_positions;
CREATE TRIGGER enforce_exempt_currency
  BEFORE INSERT OR UPDATE ON exempt_positions
  FOR EACH ROW
  EXECUTE FUNCTION validate_currency_matches_model();

-- Standardize existing OPEX data to match model currency
UPDATE opex_lines o
SET currency = (
  SELECT (data->>'model_currency')::TEXT
  FROM model_parameters mp
  WHERE mp.model_id = o.model_id 
    AND mp.parameter_type = 'finance'
  LIMIT 1
)
WHERE EXISTS (
  SELECT 1 
  FROM model_parameters mp 
  WHERE mp.model_id = o.model_id 
    AND mp.parameter_type = 'finance'
    AND (mp.data->>'model_currency')::TEXT IS NOT NULL
);

-- Standardize existing IMPEX data to match model currency
UPDATE impex_lines i
SET currency = (
  SELECT (data->>'model_currency')::TEXT
  FROM model_parameters mp
  WHERE mp.model_id = i.model_id 
    AND mp.parameter_type = 'finance'
  LIMIT 1
)
WHERE EXISTS (
  SELECT 1 
  FROM model_parameters mp 
  WHERE mp.model_id = i.model_id 
    AND mp.parameter_type = 'finance'
    AND (mp.data->>'model_currency')::TEXT IS NOT NULL
);

-- Standardize existing Equipment data to match model currency
UPDATE equipment e
SET currency_code = (
  SELECT (data->>'model_currency')::TEXT
  FROM model_parameters mp
  WHERE mp.model_id = e.model_id 
    AND mp.parameter_type = 'finance'
  LIMIT 1
)
WHERE e.model_id IS NOT NULL
  AND EXISTS (
    SELECT 1 
    FROM model_parameters mp 
    WHERE mp.model_id = e.model_id 
      AND mp.parameter_type = 'finance'
      AND (mp.data->>'model_currency')::TEXT IS NOT NULL
  );

-- Standardize existing Nonexempt Positions data to match model currency
UPDATE nonexempt_positions np
SET currency = (
  SELECT (data->>'model_currency')::TEXT
  FROM model_parameters mp
  WHERE mp.model_id = np.model_id 
    AND mp.parameter_type = 'finance'
  LIMIT 1
)
WHERE EXISTS (
  SELECT 1 
  FROM model_parameters mp 
  WHERE mp.model_id = np.model_id 
    AND mp.parameter_type = 'finance'
    AND (mp.data->>'model_currency')::TEXT IS NOT NULL
);

-- Standardize existing Exempt Positions data to match model currency
UPDATE exempt_positions ep
SET currency = (
  SELECT (data->>'model_currency')::TEXT
  FROM model_parameters mp
  WHERE mp.model_id = ep.model_id 
    AND mp.parameter_type = 'finance'
  LIMIT 1
)
WHERE EXISTS (
  SELECT 1 
  FROM model_parameters mp 
  WHERE mp.model_id = ep.model_id 
    AND mp.parameter_type = 'finance'
    AND (mp.data->>'model_currency')::TEXT IS NOT NULL
);