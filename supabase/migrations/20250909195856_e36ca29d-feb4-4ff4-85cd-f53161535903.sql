-- Tighten profiles SELECT access: restrict to authenticated users only
-- Keep existing INSERT/UPDATE policies intact

-- Ensure RLS is enabled (idempotent)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop broad SELECT policy if it exists
DROP POLICY IF EXISTS "Users can view their own profile and admins can view all" ON public.profiles;

-- Create explicit SELECT policies limited to authenticated users
CREATE POLICY "Users can view their own profile"
ON public.profiles
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all profiles"
ON public.profiles
FOR SELECT
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role));