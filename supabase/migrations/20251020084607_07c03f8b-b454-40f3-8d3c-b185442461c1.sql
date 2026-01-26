-- Fix INSERT policies for library tables to work with upsert
-- The issue: upsert checks both INSERT and UPDATE policies
-- The fix: Make INSERT policies check permissions instead of created_by

-- 1. Fix library_exempt_positions
DROP POLICY IF EXISTS "Users can create library exempt positions" ON library_exempt_positions;

CREATE POLICY "Users with library permission can create exempt positions"
ON library_exempt_positions
FOR INSERT
TO public
WITH CHECK (
  has_permission(auth.uid(), 'library.view'::permission_type)
);

-- 2. Fix library_nonexempt_positions
DROP POLICY IF EXISTS "Users can create library nonexempt positions" ON library_nonexempt_positions;

CREATE POLICY "Users with library permission can create nonexempt positions"
ON library_nonexempt_positions
FOR INSERT
TO public
WITH CHECK (
  has_permission(auth.uid(), 'library.view'::permission_type)
);

-- 3. Fix library_schedules
DROP POLICY IF EXISTS "Users can create library schedules" ON library_schedules;

CREATE POLICY "Users with library permission can create schedules"
ON library_schedules
FOR INSERT
TO public
WITH CHECK (
  has_permission(auth.uid(), 'library.view'::permission_type)
);

-- 4. Fix library_equipment
DROP POLICY IF EXISTS "Users can create library equipment" ON library_equipment;

CREATE POLICY "Users with library permission can create equipment"
ON library_equipment
FOR INSERT
TO public
WITH CHECK (
  has_permission(auth.uid(), 'library.view'::permission_type)
);

-- 5. Fix approved_job_titles (only if INSERT policy exists)
DROP POLICY IF EXISTS "Users can create job titles" ON approved_job_titles;

CREATE POLICY "Admins can create job titles"
ON approved_job_titles
FOR INSERT
TO public
WITH CHECK (
  has_role(auth.uid(), 'admin'::app_role)
);