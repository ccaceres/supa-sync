-- Add unique constraint to prevent duplicate equipment names per model and year
-- This ensures no two equipment items can have the same name within a model for a given year

-- First, check if there are any existing duplicates and handle them
-- We'll add a suffix to duplicates to make them unique
DO $$
DECLARE
  duplicate_record RECORD;
  counter INTEGER;
BEGIN
  -- Find and fix duplicates by adding a suffix
  FOR duplicate_record IN
    SELECT model_id, equipment_name, year, array_agg(id ORDER BY created_at) as ids
    FROM equipment
    WHERE year IS NOT NULL
    GROUP BY model_id, equipment_name, year
    HAVING COUNT(*) > 1
  LOOP
    counter := 2;
    -- Update all but the first record with a suffix
    FOR i IN 2..array_length(duplicate_record.ids, 1) LOOP
      UPDATE equipment
      SET equipment_name = duplicate_record.equipment_name || ' (' || counter || ')'
      WHERE id = duplicate_record.ids[i];
      counter := counter + 1;
    END LOOP;
  END LOOP;
END $$;

-- Add unique constraint on (model_id, equipment_name, year)
-- Note: We only enforce uniqueness when year is NOT NULL
-- If year IS NULL, multiple equipment with same name are allowed
CREATE UNIQUE INDEX IF NOT EXISTS idx_equipment_unique_name_per_model_year
ON equipment (model_id, equipment_name, year)
WHERE year IS NOT NULL;

-- Add a comment explaining the constraint
COMMENT ON INDEX idx_equipment_unique_name_per_model_year IS 
'Ensures equipment names are unique per model and year. Allows NULL years to have duplicates.';