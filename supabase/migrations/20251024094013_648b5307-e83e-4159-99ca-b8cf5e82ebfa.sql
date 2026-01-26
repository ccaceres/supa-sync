-- ============================================
-- SCHEDULE LINKING MIGRATION (FIXED)
-- ============================================
-- Purpose: Enable model-specific schedule linking while preserving existing DL Roles
-- Pattern: Same as Equipment/Positions (using library_object_usage)
-- Key: Read-only references (no local copies)

-- 1. Create index for performance
CREATE INDEX IF NOT EXISTS idx_library_object_usage_schedule 
ON library_object_usage(model_id, library_object_type) 
WHERE library_object_type = 'Schedule';

-- 2. Create view for easy querying
CREATE OR REPLACE VIEW model_schedules AS
SELECT 
  lou.model_id,
  lou.id as usage_id,
  lou.model_object_id,
  lou.library_object_id,
  lou.is_modified,
  lou.last_synced,
  lou.sync_status,
  lou.linked_at,
  lou.linked_by,
  ls.*
FROM library_object_usage lou
INNER JOIN library_schedules ls ON lou.library_object_id = ls.id
WHERE lou.library_object_type = 'Schedule';

COMMENT ON VIEW model_schedules IS 'Model-linked schedules (read-only references from library)';

-- 3. AUTO-MIGRATE: Link schedules currently used by DL Roles
INSERT INTO library_object_usage (
  model_id,
  library_object_id,
  model_object_id,
  library_object_type,
  library_version,
  local_version,
  sync_status,
  is_modified,
  linked_at,
  linked_by
)
SELECT DISTINCT
  dr.model_id,
  dr.schedule_id,
  dr.schedule_id,
  'Schedule',
  1,
  1,
  'synced',
  false,
  NOW(),
  auth.uid()
FROM dl_roles_library dr
WHERE dr.schedule_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM library_object_usage
    WHERE model_id = dr.model_id
      AND library_object_id = dr.schedule_id
      AND library_object_type = 'Schedule'
  )
ON CONFLICT DO NOTHING;