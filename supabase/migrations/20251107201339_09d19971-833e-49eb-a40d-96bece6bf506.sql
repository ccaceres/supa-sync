-- Fix recovery_method default value mismatch
-- Change default from 'amortized' to 'upfront' to match application behavior
ALTER TABLE impex_lines 
ALTER COLUMN recovery_method SET DEFAULT 'upfront';