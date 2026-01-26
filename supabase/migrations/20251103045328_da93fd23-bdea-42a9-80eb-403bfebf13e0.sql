-- Add purchase_maintenance_cost_per_year column to equipment table
-- This field is needed for formula calculations to determine yearly maintenance costs for purchased equipment

ALTER TABLE equipment 
ADD COLUMN IF NOT EXISTS purchase_maintenance_cost_per_year DECIMAL(15,2) DEFAULT 0;

COMMENT ON COLUMN equipment.purchase_maintenance_cost_per_year IS 'Annual maintenance cost for purchased equipment';