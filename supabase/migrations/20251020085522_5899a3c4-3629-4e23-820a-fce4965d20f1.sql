-- Drop old owner-based policies for library_schedules
DROP POLICY IF EXISTS "Users can update library schedules they created" ON library_schedules;
DROP POLICY IF EXISTS "Users can delete library schedules they created" ON library_schedules;

-- Create new permission-based policies
CREATE POLICY "Users with library permission can update schedules"
ON library_schedules
FOR UPDATE
TO public
USING (has_permission(auth.uid(), 'library.view'::permission_type))
WITH CHECK (has_permission(auth.uid(), 'library.view'::permission_type));

CREATE POLICY "Users with library permission can delete schedules"
ON library_schedules
FOR DELETE
TO public
USING (has_permission(auth.uid(), 'library.view'::permission_type));