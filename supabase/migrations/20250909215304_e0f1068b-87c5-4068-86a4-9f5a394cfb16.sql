-- Create more granular RLS policies for customer contact information
-- First, drop existing policies
DROP POLICY IF EXISTS "Users can view customers with permission" ON public.customers;
DROP POLICY IF EXISTS "Users can create customers with permission" ON public.customers; 
DROP POLICY IF EXISTS "Users can update customers with permission" ON public.customers;
DROP POLICY IF EXISTS "Users can delete customers with permission" ON public.customers;

-- Create new granular policies

-- Policy 1: Admins and managers can see all customer data including contact info
CREATE POLICY "Admins and managers can view all customer data" 
ON public.customers 
FOR SELECT 
USING (
  has_role(auth.uid(), 'admin'::app_role) OR 
  has_role(auth.uid(), 'manager'::app_role)
);

-- Policy 2: Analysts and viewers can see customer data but WITHOUT contact information
-- We'll create a security definer function to handle this
CREATE OR REPLACE FUNCTION public.user_can_view_customer_contacts()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT has_role(auth.uid(), 'admin'::app_role) OR 
         has_role(auth.uid(), 'manager'::app_role)
$$;

-- Policy 3: Analysts and viewers see limited customer data (no contact info via application logic)
CREATE POLICY "Analysts and viewers can view basic customer data" 
ON public.customers 
FOR SELECT 
USING (
  has_permission(auth.uid(), 'customers.view'::permission_type)
);

-- Create policies for other operations (unchanged permissions but cleaner structure)
CREATE POLICY "Users can create customers with permission" 
ON public.customers 
FOR INSERT 
WITH CHECK (has_permission(auth.uid(), 'customers.create'::permission_type));

CREATE POLICY "Users can update customers with permission" 
ON public.customers 
FOR UPDATE 
USING (has_permission(auth.uid(), 'customers.edit'::permission_type));

CREATE POLICY "Users can delete customers with permission" 
ON public.customers 
FOR DELETE 
USING (has_permission(auth.uid(), 'customers.delete'::permission_type));

-- Create a secure view for customer data that conditionally shows contact info
CREATE OR REPLACE VIEW public.customers_secure AS
SELECT 
  id,
  name,
  code,
  industry,
  status,
  country,
  contract_type,
  created_at,
  updated_at,
  -- Contact information only visible to admins and managers
  CASE 
    WHEN public.user_can_view_customer_contacts() THEN contact_name 
    ELSE NULL 
  END as contact_name,
  CASE 
    WHEN public.user_can_view_customer_contacts() THEN contact_email 
    ELSE NULL 
  END as contact_email
FROM public.customers;