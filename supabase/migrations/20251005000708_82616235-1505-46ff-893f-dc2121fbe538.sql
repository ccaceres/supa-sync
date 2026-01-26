-- Add index for efficient state/city queries
CREATE INDEX IF NOT EXISTS idx_cities_country_state 
ON cities(country_code, state);

-- Add index for country lookups
CREATE INDEX IF NOT EXISTS idx_cities_country 
ON cities(country_code);