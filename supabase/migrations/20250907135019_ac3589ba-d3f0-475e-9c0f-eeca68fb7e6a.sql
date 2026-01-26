-- Add missing columns to projects table if they don't exist
DO $$ 
BEGIN
  -- Add customer_id if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'customer_id') THEN
    ALTER TABLE public.projects ADD COLUMN customer_id UUID;
  END IF;

  -- Add other missing columns
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'code') THEN
    ALTER TABLE public.projects ADD COLUMN code VARCHAR;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'description') THEN
    ALTER TABLE public.projects ADD COLUMN description TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'type') THEN
    ALTER TABLE public.projects ADD COLUMN type VARCHAR DEFAULT 'New Business';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'opportunity_value') THEN
    ALTER TABLE public.projects ADD COLUMN opportunity_value NUMERIC;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'probability') THEN
    ALTER TABLE public.projects ADD COLUMN probability INTEGER;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'expected_revenue') THEN
    ALTER TABLE public.projects ADD COLUMN expected_revenue NUMERIC;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'start_date') THEN
    ALTER TABLE public.projects ADD COLUMN start_date DATE;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'end_date') THEN
    ALTER TABLE public.projects ADD COLUMN end_date DATE;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'decision_date') THEN
    ALTER TABLE public.projects ADD COLUMN decision_date DATE;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'country') THEN
    ALTER TABLE public.projects ADD COLUMN country VARCHAR;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'state') THEN
    ALTER TABLE public.projects ADD COLUMN state VARCHAR;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'city') THEN
    ALTER TABLE public.projects ADD COLUMN city VARCHAR;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'site_name') THEN
    ALTER TABLE public.projects ADD COLUMN site_name VARCHAR;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'owned_by') THEN
    ALTER TABLE public.projects ADD COLUMN owned_by UUID;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'projects' AND column_name = 'archived_at') THEN
    ALTER TABLE public.projects ADD COLUMN archived_at TIMESTAMP WITH TIME ZONE;
  END IF;
END $$;

-- Add missing columns to models table if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'major_version') THEN
    ALTER TABLE public.models ADD COLUMN major_version INTEGER DEFAULT 1;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'minor_version') THEN
    ALTER TABLE public.models ADD COLUMN minor_version INTEGER DEFAULT 0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'patch_version') THEN
    ALTER TABLE public.models ADD COLUMN patch_version INTEGER DEFAULT 0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'version_notes') THEN
    ALTER TABLE public.models ADD COLUMN version_notes TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'copied_from_id') THEN
    ALTER TABLE public.models ADD COLUMN copied_from_id UUID;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'copy_date') THEN
    ALTER TABLE public.models ADD COLUMN copy_date TIMESTAMP WITH TIME ZONE;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'locked') THEN
    ALTER TABLE public.models ADD COLUMN locked BOOLEAN DEFAULT false;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'lock_reason') THEN
    ALTER TABLE public.models ADD COLUMN lock_reason TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'submitted_at') THEN
    ALTER TABLE public.models ADD COLUMN submitted_at TIMESTAMP WITH TIME ZONE;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'approved_at') THEN
    ALTER TABLE public.models ADD COLUMN approved_at TIMESTAMP WITH TIME ZONE;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'closed_at') THEN
    ALTER TABLE public.models ADD COLUMN closed_at TIMESTAMP WITH TIME ZONE;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'last_modified_by') THEN
    ALTER TABLE public.models ADD COLUMN last_modified_by UUID;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'approved_by') THEN
    ALTER TABLE public.models ADD COLUMN approved_by UUID;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'total_revenue') THEN
    ALTER TABLE public.models ADD COLUMN total_revenue NUMERIC;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'total_cost') THEN
    ALTER TABLE public.models ADD COLUMN total_cost NUMERIC;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'ebitda') THEN
    ALTER TABLE public.models ADD COLUMN ebitda NUMERIC;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'margin_percentage') THEN
    ALTER TABLE public.models ADD COLUMN margin_percentage NUMERIC;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'irr') THEN
    ALTER TABLE public.models ADD COLUMN irr NUMERIC;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'models' AND column_name = 'npv') THEN
    ALTER TABLE public.models ADD COLUMN npv NUMERIC;
  END IF;
END $$;

-- Enable RLS on customers if not already enabled
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for customers if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'customers' AND policyname = 'Users can view all customers') THEN
    CREATE POLICY "Users can view all customers" 
    ON public.customers 
    FOR SELECT 
    USING (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'customers' AND policyname = 'Users can create customers') THEN
    CREATE POLICY "Users can create customers" 
    ON public.customers 
    FOR INSERT 
    WITH CHECK (auth.uid() IS NOT NULL);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'customers' AND policyname = 'Users can update customers') THEN
    CREATE POLICY "Users can update customers" 
    ON public.customers 
    FOR UPDATE 
    USING (auth.uid() IS NOT NULL);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'customers' AND policyname = 'Users can delete customers') THEN
    CREATE POLICY "Users can delete customers" 
    ON public.customers 
    FOR DELETE 
    USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Add foreign key constraint for customer_id if not exists
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                 WHERE constraint_name = 'projects_customer_id_fkey') THEN
    ALTER TABLE public.projects ADD CONSTRAINT projects_customer_id_fkey 
    FOREIGN KEY (customer_id) REFERENCES public.customers(id);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                 WHERE constraint_name = 'models_copied_from_id_fkey') THEN
    ALTER TABLE public.models ADD CONSTRAINT models_copied_from_id_fkey 
    FOREIGN KEY (copied_from_id) REFERENCES public.models(id);
  END IF;
END $$;