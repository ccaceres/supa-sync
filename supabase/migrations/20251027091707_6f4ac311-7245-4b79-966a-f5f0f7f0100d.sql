-- Add equipment_factor column to equipment table
ALTER TABLE equipment 
ADD COLUMN IF NOT EXISTS equipment_factor NUMERIC DEFAULT 100 
CHECK (equipment_factor > 0);

COMMENT ON COLUMN equipment.equipment_factor IS 'Equipment factor percentage (e.g., 100 = 1 equipment per HC). Used in formula: ROUNDUP(MaxOperatingHeadcount * EquipmentFactor / 100)';

-- Update existing equipment records to have default equipment_factor
UPDATE equipment 
SET equipment_factor = 100 
WHERE equipment_factor IS NULL;