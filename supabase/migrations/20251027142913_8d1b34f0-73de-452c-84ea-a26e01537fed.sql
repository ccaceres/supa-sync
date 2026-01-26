-- Add equipment_set_id column to equipment table to track which equipment set an item belongs to
ALTER TABLE equipment 
ADD COLUMN equipment_set_id UUID REFERENCES equipment_sets(id) ON DELETE SET NULL;

-- Create index for better query performance
CREATE INDEX idx_equipment_equipment_set_id ON equipment(equipment_set_id);

-- Add comment to explain the column
COMMENT ON COLUMN equipment.equipment_set_id IS 'Optional reference to the equipment set this equipment item belongs to or was added from';