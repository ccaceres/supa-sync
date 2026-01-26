-- Security hardening: Add SET search_path for database functions that are missing it
-- This prevents potential security issues with function resolution

-- Update ensure_single_approved_model function
CREATE OR REPLACE FUNCTION public.ensure_single_approved_model()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = 'public'
AS $function$
BEGIN
    -- If the model is being set to 'Approved' status
    IF NEW.status = 'Approved' AND (OLD.status IS NULL OR OLD.status != 'Approved') THEN
        -- Set all other approved models in the same project to 'Superseded'
        UPDATE models 
        SET status = 'Superseded', 
            updated_at = NOW()
        WHERE project_id = NEW.project_id 
          AND id != NEW.id 
          AND status = 'Approved';
    END IF;
    
    RETURN NEW;
END;
$function$;

-- Update track_object_link_audit function
CREATE OR REPLACE FUNCTION public.track_object_link_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = 'public'
AS $function$
BEGIN
    -- Insert audit record for INSERT operations
    IF TG_OP = 'INSERT' THEN
        INSERT INTO object_link_audit (
            model_id, object_type, library_object_id, local_object_id,
            action, user_id, new_values
        ) VALUES (
            NEW.model_id, NEW.library_object_type, NEW.library_object_id, NEW.model_object_id,
            'linked', auth.uid(), row_to_json(NEW)
        );
        RETURN NEW;
    END IF;
    
    -- Insert audit record for UPDATE operations  
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO object_link_audit (
            model_id, object_type, library_object_id, local_object_id,
            action, user_id, old_values, new_values
        ) VALUES (
            NEW.model_id, NEW.library_object_type, NEW.library_object_id, NEW.model_object_id,
            'updated', auth.uid(), row_to_json(OLD), row_to_json(NEW)
        );
        RETURN NEW;
    END IF;
    
    -- Insert audit record for DELETE operations
    IF TG_OP = 'DELETE' THEN
        INSERT INTO object_link_audit (
            model_id, object_type, library_object_id, local_object_id,
            action, user_id, old_values
        ) VALUES (
            OLD.model_id, OLD.library_object_type, OLD.library_object_id, OLD.model_object_id,
            'unlinked', auth.uid(), row_to_json(OLD)
        );
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$function$;

-- Update handle_invitation_signup function
CREATE OR REPLACE FUNCTION public.handle_invitation_signup()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = 'public'
AS $function$
DECLARE
    invitation_record RECORD;
BEGIN
    -- Check if there's a pending invitation for this user's email
    SELECT * INTO invitation_record
    FROM public.user_invitations
    WHERE email = NEW.raw_user_meta_data->>'email'
    AND accepted_at IS NOT NULL
    AND expires_at > NOW()
    LIMIT 1;
    
    -- If invitation exists, assign the role
    IF invitation_record.id IS NOT NULL THEN
        INSERT INTO public.user_roles (user_id, role, assigned_by)
        VALUES (NEW.id, invitation_record.role, invitation_record.invited_by);
    END IF;
    
    RETURN NEW;
END;
$function$;

-- Update calculate_capex_total_investment function
CREATE OR REPLACE FUNCTION public.calculate_capex_total_investment()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path = 'public'
AS $function$
BEGIN
    -- Calculate total investment based on quantity and unit cost
    NEW.total_investment = COALESCE(NEW.quantity, 0) * COALESCE(NEW.unit_cost, 0);
    
    RETURN NEW;
END;
$function$;

-- Update calculate_impex_total_cost function
CREATE OR REPLACE FUNCTION public.calculate_impex_total_cost()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path = 'public'
AS $function$
BEGIN
    -- Calculate base total cost
    NEW.total_cost = COALESCE(NEW.quantity, 0) * COALESCE(NEW.unit_cost, 0);
    
    -- Calculate total upfront for upfront charging method
    IF NEW.charging_method = 'upfront' AND NEW.margin_markup IS NOT NULL AND NEW.charging_treatment IS NOT NULL THEN
        IF NEW.charging_treatment = 0 THEN
            -- Margin calculation: Cost / (1 - margin%)
            NEW.total_upfront = NEW.total_cost / (1 - (NEW.margin_markup / 100));
        ELSE
            -- Markup calculation: Cost * (1 + markup%)
            NEW.total_upfront = NEW.total_cost * (1 + (NEW.margin_markup / 100));
        END IF;
    ELSE
        NEW.total_upfront = NEW.total_cost;
    END IF;
    
    RETURN NEW;
END;
$function$;

-- Update update_impex_row_order function
CREATE OR REPLACE FUNCTION public.update_impex_row_order()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path = 'public'
AS $function$
BEGIN
    IF NEW.row_order IS NULL OR NEW.row_order = 0 THEN
        SELECT COALESCE(MAX(row_order), 0) + 1 
        INTO NEW.row_order 
        FROM impex_lines 
        WHERE model_id = NEW.model_id;
    END IF;
    RETURN NEW;
END;
$function$;