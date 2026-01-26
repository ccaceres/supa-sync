-- Function to update library schedules
CREATE OR REPLACE FUNCTION update_library_schedule(
  p_id UUID,
  p_updates JSONB
)
RETURNS SETOF library_schedules
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  UPDATE library_schedules
  SET
    name = COALESCE((p_updates->>'name')::TEXT, name),
    description = COALESCE((p_updates->>'description')::TEXT, description),
    is_active = COALESCE((p_updates->>'is_active')::BOOLEAN, is_active),
    updated_at = NOW()
  WHERE id = p_id
  RETURNING *;
END;
$$;

-- Function to update library nonexempt positions
CREATE OR REPLACE FUNCTION update_library_nonexempt_position(
  p_id UUID,
  p_updates JSONB
)
RETURNS SETOF library_nonexempt_positions
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  UPDATE library_nonexempt_positions
  SET
    position_name = COALESCE((p_updates->>'position_name')::TEXT, position_name),
    job_title_id = COALESCE((p_updates->>'job_title_id')::UUID, job_title_id),
    project = COALESCE((p_updates->>'project')::TEXT, project),
    year = COALESCE((p_updates->>'year')::INTEGER, year),
    country = COALESCE((p_updates->>'country')::TEXT, country),
    state = COALESCE((p_updates->>'state')::TEXT, state),
    city = COALESCE((p_updates->>'city')::TEXT, city),
    currency = COALESCE((p_updates->>'currency')::TEXT, currency),
    base_hourly_rate = COALESCE((p_updates->>'base_hourly_rate')::NUMERIC, base_hourly_rate),
    shift_differential = COALESCE((p_updates->>'shift_differential')::NUMERIC, shift_differential),
    overtime_multiplier = COALESCE((p_updates->>'overtime_multiplier')::NUMERIC, overtime_multiplier),
    is_active = COALESCE((p_updates->>'is_active')::BOOLEAN, is_active),
    updated_at = NOW()
  WHERE id = p_id
  RETURNING *;
END;
$$;

-- Function to update library exempt positions
CREATE OR REPLACE FUNCTION update_library_exempt_position(
  p_id UUID,
  p_updates JSONB
)
RETURNS SETOF library_exempt_positions
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  UPDATE library_exempt_positions
  SET
    position_name = COALESCE((p_updates->>'position_name')::TEXT, position_name),
    job_title_id = COALESCE((p_updates->>'job_title_id')::UUID, job_title_id),
    project = COALESCE((p_updates->>'project')::TEXT, project),
    year = COALESCE((p_updates->>'year')::INTEGER, year),
    country = COALESCE((p_updates->>'country')::TEXT, country),
    state = COALESCE((p_updates->>'state')::TEXT, state),
    city = COALESCE((p_updates->>'city')::TEXT, city),
    currency = COALESCE((p_updates->>'currency')::TEXT, currency),
    annual_salary = COALESCE((p_updates->>'annual_salary')::NUMERIC, annual_salary),
    is_active = COALESCE((p_updates->>'is_active')::BOOLEAN, is_active),
    updated_at = NOW()
  WHERE id = p_id
  RETURNING *;
END;
$$;

-- Function to update library equipment
CREATE OR REPLACE FUNCTION update_library_equipment(
  p_id UUID,
  p_updates JSONB
)
RETURNS SETOF library_equipment
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  UPDATE library_equipment
  SET
    equipment_name = COALESCE((p_updates->>'equipment_name')::TEXT, equipment_name),
    equipment_type = COALESCE((p_updates->>'equipment_type')::TEXT, equipment_type),
    manufacturer = COALESCE((p_updates->>'manufacturer')::TEXT, manufacturer),
    model_number = COALESCE((p_updates->>'model_number')::TEXT, model_number),
    year = COALESCE((p_updates->>'year')::INTEGER, year),
    country = COALESCE((p_updates->>'country')::TEXT, country),
    currency = COALESCE((p_updates->>'currency')::TEXT, currency),
    unit_cost = COALESCE((p_updates->>'unit_cost')::NUMERIC, unit_cost),
    useful_life_years = COALESCE((p_updates->>'useful_life_years')::INTEGER, useful_life_years),
    category = COALESCE((p_updates->>'category')::TEXT, category),
    is_active = COALESCE((p_updates->>'is_active')::BOOLEAN, is_active),
    updated_at = NOW()
  WHERE id = p_id
  RETURNING *;
END;
$$;

-- Function to update library job titles
CREATE OR REPLACE FUNCTION update_library_job_title(
  p_id UUID,
  p_updates JSONB
)
RETURNS SETOF approved_job_titles
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  UPDATE approved_job_titles
  SET
    title = COALESCE((p_updates->>'title')::TEXT, title),
    classification = COALESCE((p_updates->>'classification')::TEXT, classification),
    category = COALESCE((p_updates->>'category')::TEXT, category),
    is_exempt = COALESCE((p_updates->>'is_exempt')::BOOLEAN, is_exempt),
    is_active = COALESCE((p_updates->>'is_active')::BOOLEAN, is_active),
    updated_at = NOW()
  WHERE id = p_id
  RETURNING *;
END;
$$;