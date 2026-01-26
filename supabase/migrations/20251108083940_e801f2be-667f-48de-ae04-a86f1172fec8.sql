-- Add soft delete support to equipment table
-- This allows equipment to be "deleted" without losing data, and can be restored later

-- Add deleted_at timestamp column to equipment table
ALTER TABLE equipment
ADD COLUMN IF NOT EXISTS deleted_at timestamp with time zone DEFAULT NULL;

-- Add index on deleted_at for better query performance
CREATE INDEX IF NOT EXISTS idx_equipment_deleted_at ON equipment(deleted_at) WHERE deleted_at IS NULL;

-- Add comment explaining the soft delete functionality
COMMENT ON COLUMN equipment.deleted_at IS 
'Timestamp when equipment was soft-deleted. NULL means equipment is active. Non-NULL means equipment is deleted but can be restored.';