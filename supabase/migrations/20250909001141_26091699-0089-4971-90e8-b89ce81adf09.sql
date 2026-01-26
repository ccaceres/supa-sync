-- Enhance capex_lines table to match CAPEX specification
ALTER TABLE capex_lines 
ADD COLUMN IF NOT EXISTS item_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS quantity NUMERIC DEFAULT 1,
ADD COLUMN IF NOT EXISTS unit_cost NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS unit_of_measure VARCHAR(100) DEFAULT 'Each',
ADD COLUMN IF NOT EXISTS investment_year INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS salvage_percentage NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS equipment_id UUID REFERENCES equipment(id),
ADD COLUMN IF NOT EXISTS driver_id UUID,
ADD COLUMN IF NOT EXISTS driver_ratio NUMERIC DEFAULT 1,
ADD COLUMN IF NOT EXISTS notes TEXT,
ADD COLUMN IF NOT EXISTS total_investment NUMERIC GENERATED ALWAYS AS (quantity * unit_cost) STORED,
ADD COLUMN IF NOT EXISTS row_order INTEGER DEFAULT 0;

-- Update existing records to have proper item names based on description
UPDATE capex_lines SET item_name = COALESCE(description, 'Investment Item') WHERE item_name IS NULL;

-- Make item_name not null after setting default values
ALTER TABLE capex_lines ALTER COLUMN item_name SET NOT NULL;

-- Add constraints for data validation
ALTER TABLE capex_lines 
ADD CONSTRAINT quantity_positive CHECK (quantity > 0),
ADD CONSTRAINT unit_cost_non_negative CHECK (unit_cost >= 0),
ADD CONSTRAINT investment_year_valid CHECK (investment_year >= 0 AND investment_year <= 10),
ADD CONSTRAINT salvage_percentage_valid CHECK (salvage_percentage >= 0 AND salvage_percentage <= 100),
ADD CONSTRAINT depreciation_years_valid CHECK (depreciation_years >= 1 AND depreciation_years <= 20),
ADD CONSTRAINT driver_ratio_positive CHECK (driver_ratio > 0);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_capex_lines_model_investment_year ON capex_lines(model_id, investment_year);
CREATE INDEX IF NOT EXISTS idx_capex_lines_equipment ON capex_lines(equipment_id) WHERE equipment_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_capex_lines_driver ON capex_lines(driver_id) WHERE driver_id IS NOT NULL;

-- Create function to update row_order automatically
CREATE OR REPLACE FUNCTION update_capex_row_order()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.row_order IS NULL OR NEW.row_order = 0 THEN
        SELECT COALESCE(MAX(row_order), 0) + 1 
        INTO NEW.row_order 
        FROM capex_lines 
        WHERE model_id = NEW.model_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for auto row ordering
DROP TRIGGER IF EXISTS trigger_capex_row_order ON capex_lines;
CREATE TRIGGER trigger_capex_row_order
    BEFORE INSERT ON capex_lines
    FOR EACH ROW
    EXECUTE FUNCTION update_capex_row_order();