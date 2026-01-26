-- Delete all duplicate records, keeping only the newest one per (model_id, exempt_position_id, shift) group
WITH duplicate_groups AS (
  SELECT 
    model_id, 
    exempt_position_id, 
    shift,
    COUNT(*) as dup_count
  FROM labex_indirect_labor
  GROUP BY model_id, exempt_position_id, shift
  HAVING COUNT(*) > 1
),
records_to_delete AS (
  SELECT l.id
  FROM labex_indirect_labor l
  INNER JOIN duplicate_groups dg 
    ON l.model_id = dg.model_id 
    AND l.exempt_position_id = dg.exempt_position_id 
    AND l.shift = dg.shift
  WHERE l.id NOT IN (
    -- Keep only the newest record per group
    SELECT id FROM (
      SELECT 
        id,
        ROW_NUMBER() OVER (
          PARTITION BY model_id, exempt_position_id, shift 
          ORDER BY created_at DESC
        ) as rn
      FROM labex_indirect_labor
    ) ranked
    WHERE rn = 1
  )
)
DELETE FROM labex_indirect_labor
WHERE id IN (SELECT id FROM records_to_delete);

-- Add unique constraint to prevent future duplicates
ALTER TABLE labex_indirect_labor
ADD CONSTRAINT unique_position_shift_per_model 
UNIQUE (model_id, exempt_position_id, shift);