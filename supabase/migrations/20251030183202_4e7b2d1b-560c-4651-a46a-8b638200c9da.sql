-- Add RLS policy for authenticated users to view cities
CREATE POLICY "Authenticated users can view cities"
ON cities
FOR SELECT
TO authenticated
USING (true);