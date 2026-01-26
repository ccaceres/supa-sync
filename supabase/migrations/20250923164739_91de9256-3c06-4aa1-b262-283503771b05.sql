-- Fix security warning: Function search_path mutable
CREATE OR REPLACE FUNCTION has_pending_hr_requests(p_model_id UUID)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE SECURITY DEFINER
SET search_path = 'public'
AS $$
    SELECT EXISTS (
        SELECT 1 FROM direct_roles 
        WHERE model_id = p_model_id AND status = 'awaiting_hr_input'
        UNION
        SELECT 1 FROM salary_roles 
        WHERE model_id = p_model_id AND status = 'awaiting_hr_input'
    )
$$;