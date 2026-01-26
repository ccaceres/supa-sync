-- Phase 1: Fix Function Search Paths (Security Hardening)
-- Dynamically add search_path to all custom functions in the public schema
-- This prevents SQL injection via search path manipulation

DO $$ 
DECLARE
  func_record RECORD;
  func_count INTEGER := 0;
BEGIN
  -- Find all functions in public schema that don't have search_path set
  FOR func_record IN 
    SELECT 
      p.oid,
      n.nspname as schema_name,
      p.proname as function_name,
      pg_get_function_identity_arguments(p.oid) as args
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
    AND p.proname NOT LIKE 'pg_%'
    AND p.proname NOT LIKE 'auth_%'
    AND p.proname NOT LIKE 'supabase_%'
    AND (p.proconfig IS NULL OR NOT EXISTS (
      SELECT 1 FROM unnest(p.proconfig) AS config 
      WHERE config LIKE 'search_path=%'
    ))
  LOOP
    BEGIN
      -- Set search_path for the function
      EXECUTE format(
        'ALTER FUNCTION %I.%I(%s) SET search_path = public, pg_temp',
        func_record.schema_name,
        func_record.function_name,
        func_record.args
      );
      
      func_count := func_count + 1;
      RAISE NOTICE 'Fixed search_path for function: %.%(%)', 
        func_record.schema_name, func_record.function_name, func_record.args;
        
    EXCEPTION WHEN OTHERS THEN
      -- Log but continue if any function fails
      RAISE WARNING 'Could not fix search_path for %.%(%). Error: %', 
        func_record.schema_name, func_record.function_name, func_record.args, SQLERRM;
    END;
  END LOOP;
  
  RAISE NOTICE 'Phase 1 Complete: Fixed search_path for % functions', func_count;
END $$;