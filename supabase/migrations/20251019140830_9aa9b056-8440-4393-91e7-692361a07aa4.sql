-- Fix RLS policies to use library.view permission instead of library.edit
-- This allows users who can view library items to also edit them

-- Drop the policies that require library.edit
DROP POLICY IF EXISTS "Users with library edit permission can update exempt positions" ON library_exempt_positions;
DROP POLICY IF EXISTS "Users with library edit permission can delete exempt positions" ON library_exempt_positions;
DROP POLICY IF EXISTS "Users with library edit permission can update nonexempt positions" ON library_nonexempt_positions;
DROP POLICY IF EXISTS "Users with library edit permission can delete nonexempt positions" ON library_nonexempt_positions;

-- Create new policies that use library.view permission (same as SELECT policy)
CREATE POLICY "Users with library view permission can update exempt positions" 
  ON library_exempt_positions 
  FOR UPDATE 
  USING (has_permission(auth.uid(), 'library.view'::permission_type));

CREATE POLICY "Users with library view permission can delete exempt positions" 
  ON library_exempt_positions 
  FOR DELETE 
  USING (has_permission(auth.uid(), 'library.view'::permission_type));

CREATE POLICY "Users with library view permission can update nonexempt positions" 
  ON library_nonexempt_positions 
  FOR UPDATE 
  USING (has_permission(auth.uid(), 'library.view'::permission_type));

CREATE POLICY "Users with library view permission can delete nonexempt positions" 
  ON library_nonexempt_positions 
  FOR DELETE 
  USING (has_permission(auth.uid(), 'library.view'::permission_type));