-- Create cities table and populate with sample data
CREATE TABLE IF NOT EXISTS public.cities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR NOT NULL,
  country_code VARCHAR NOT NULL,
  state VARCHAR,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.cities ENABLE ROW LEVEL SECURITY;

-- Create policy for viewing cities (skip if exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'cities' AND policyname = 'Anyone can view cities'
  ) THEN
    CREATE POLICY "Anyone can view cities" ON public.cities FOR SELECT USING (true);
  END IF;
END $$;

-- Insert sample cities data (only if table is empty)
INSERT INTO public.cities (name, country_code, state) 
SELECT * FROM (VALUES
  ('New York', 'US', 'New York'),
  ('Los Angeles', 'US', 'California'),
  ('Chicago', 'US', 'Illinois'),
  ('Houston', 'US', 'Texas'),
  ('Toronto', 'CA', 'Ontario'),
  ('Vancouver', 'CA', 'British Columbia'),
  ('London', 'GB', 'England'),
  ('Manchester', 'GB', 'England'),
  ('Berlin', 'DE', 'Berlin'),
  ('Munich', 'DE', 'Bavaria'),
  ('Paris', 'FR', 'Île-de-France'),
  ('Lyon', 'FR', 'Auvergne-Rhône-Alpes'),
  ('Sydney', 'AU', 'New South Wales'),
  ('Melbourne', 'AU', 'Victoria'),
  ('Tokyo', 'JP', 'Tokyo'),
  ('Osaka', 'JP', 'Osaka'),
  ('São Paulo', 'BR', 'São Paulo'),
  ('Rio de Janeiro', 'BR', 'Rio de Janeiro'),
  ('Mumbai', 'IN', 'Maharashtra'),
  ('Delhi', 'IN', 'Delhi'),
  ('Beijing', 'CN', 'Beijing'),
  ('Shanghai', 'CN', 'Shanghai')
) AS t(name, country_code, state)
WHERE NOT EXISTS (SELECT 1 FROM public.cities LIMIT 1);