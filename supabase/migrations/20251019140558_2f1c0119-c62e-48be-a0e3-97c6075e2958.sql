-- Fix RLS policies for library_exempt_positions and library_nonexempt_positions
-- Allow users with library permissions to update/delete any library position, not just ones they created

-- Drop existing policies for library_exempt_positions
DROP POLICY IF EXISTS "Users can update library exempt positions they created" ON library_exempt_positions;
DROP POLICY IF EXISTS "Users can delete library exempt positions they created" ON library_exempt_positions;

-- Create new policies that check for library permissions instead of created_by
CREATE POLICY "Users with library edit permission can update exempt positions" 
  ON library_exempt_positions 
  FOR UPDATE 
  USING (has_permission(auth.uid(), 'library.edit'::permission_type));

CREATE POLICY "Users with library edit permission can delete exempt positions" 
  ON library_exempt_positions 
  FOR DELETE 
  USING (has_permission(auth.uid(), 'library.edit'::permission_type));

-- Fix the same issue for library_nonexempt_positions
DROP POLICY IF EXISTS "Users can update library nonexempt positions they created" ON library_nonexempt_positions;
DROP POLICY IF EXISTS "Users can delete library nonexempt positions they created" ON library_nonexempt_positions;

CREATE POLICY "Users with library edit permission can update nonexempt positions" 
  ON library_nonexempt_positions 
  FOR UPDATE 
  USING (has_permission(auth.uid(), 'library.edit'::permission_type));

CREATE POLICY "Users with library edit permission can delete nonexempt positions" 
  ON library_nonexempt_positions 
  FOR DELETE 
  USING (has_permission(auth.uid(), 'library.edit'::permission_type));