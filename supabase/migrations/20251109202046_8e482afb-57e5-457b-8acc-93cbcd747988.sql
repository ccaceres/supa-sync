-- Fix IMPEX upfront_markup values stored as decimals instead of percentages
-- Convert any upfront_markup values between 0 and 1 to percentages (multiply by 100)
-- This ensures consistency with the formula engine which expects percentage values

UPDATE impex_lines
SET upfront_markup = upfront_markup * 100
WHERE upfront_markup > 0 
  AND upfront_markup < 1
  AND recovery_method = 'upfront';

-- Add a comment to document the expected format
COMMENT ON COLUMN impex_lines.upfront_markup IS 'Upfront markup as percentage (e.g., 10 for 10%, not 0.1)';