-- Add acquisition_type field to equipment_set_items to track if each item is Purchase or Lease
ALTER TABLE equipment_set_items 
ADD COLUMN acquisition_type VARCHAR(20) DEFAULT 'purchase' CHECK (acquisition_type IN ('purchase', 'lease'));