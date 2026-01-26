-- Add location columns to exempt_positions table
ALTER TABLE exempt_positions
  ADD COLUMN IF NOT EXISTS country VARCHAR,
  ADD COLUMN IF NOT EXISTS state VARCHAR,
  ADD COLUMN IF NOT EXISTS city VARCHAR,
  ADD COLUMN IF NOT EXISTS currency VARCHAR DEFAULT 'USD';

-- Set default values for existing rows
UPDATE exempt_positions 
SET country = 'United States', 
    currency = 'USD'
WHERE country IS NULL;

-- Make country and currency required
ALTER TABLE exempt_positions
  ALTER COLUMN country SET NOT NULL,
  ALTER COLUMN currency SET NOT NULL;