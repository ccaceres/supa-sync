-- Add admin override RLS policies for price_lines and related tables
-- This allows admins to view and manage all data regardless of project ownership

-- Price Lines: Admin overrides
DROP POLICY IF EXISTS "Admins have full access to price lines" ON public.price_lines;
CREATE POLICY "Admins have full access to price lines"
ON public.price_lines
FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- CAPEX Lines: Admin overrides
DROP POLICY IF EXISTS "Admins have full access to capex" ON public.capex_lines;
CREATE POLICY "Admins have full access to capex"
ON public.capex_lines
FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- IMPEX Lines: Admin overrides
DROP POLICY IF EXISTS "Admins have full access to impex" ON public.impex_lines;
CREATE POLICY "Admins have full access to impex"
ON public.impex_lines
FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Volumes: Admin overrides
DROP POLICY IF EXISTS "Admins have full access to volumes" ON public.volumes;
CREATE POLICY "Admins have full access to volumes"
ON public.volumes
FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Exempt Positions: Admin overrides
DROP POLICY IF EXISTS "Admins have full access to exempt positions" ON public.exempt_positions;
CREATE POLICY "Admins have full access to exempt positions"
ON public.exempt_positions
FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Nonexempt Positions: Admin overrides
DROP POLICY IF EXISTS "Admins have full access to nonexempt positions" ON public.nonexempt_positions;
CREATE POLICY "Admins have full access to nonexempt positions"
ON public.nonexempt_positions
FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- DL Roles: Admin overrides
DROP POLICY IF EXISTS "Admins have full access to dl roles" ON public.dl_roles;
CREATE POLICY "Admins have full access to dl roles"
ON public.dl_roles
FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Equipment: Admin overrides
DROP POLICY IF EXISTS "Admins have full access to equipment" ON public.equipment;
CREATE POLICY "Admins have full access to equipment"
ON public.equipment
FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- OPEX Lines: Admin overrides
DROP POLICY IF EXISTS "Admins have full access to opex" ON public.opex_lines;
CREATE POLICY "Admins have full access to opex"
ON public.opex_lines
FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));