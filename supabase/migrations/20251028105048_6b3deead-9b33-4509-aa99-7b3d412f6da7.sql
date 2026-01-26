-- Add equipment_factor to equipment_set_items table
ALTER TABLE equipment_set_items 
ADD COLUMN IF NOT EXISTS equipment_factor NUMERIC DEFAULT 100
CHECK (equipment_factor >= 0 AND equipment_factor <= 100);

COMMENT ON COLUMN equipment_set_items.equipment_factor IS 'Equipment productivity factor as percentage (0-100)';

-- Create equipment_price_impositions table for manual quantity overrides
CREATE TABLE IF NOT EXISTS equipment_price_impositions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  equipment_id UUID NOT NULL REFERENCES equipment(id) ON DELETE CASCADE,
  model_id UUID NOT NULL REFERENCES models(id) ON DELETE CASCADE,
  year INTEGER NOT NULL CHECK (year >= 1 AND year <= 20),
  imposed_quantity NUMERIC CHECK (imposed_quantity >= 0),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  created_by UUID REFERENCES auth.users(id),
  CONSTRAINT unique_equipment_year UNIQUE(equipment_id, year)
);

COMMENT ON TABLE equipment_price_impositions IS 'Manual quantity overrides for equipment calculations';

-- Enable RLS
ALTER TABLE equipment_price_impositions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Authenticated users can manage all price impositions
CREATE POLICY "Authenticated users can manage price impositions"
ON equipment_price_impositions FOR ALL
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_equipment_price_impositions_equipment 
ON equipment_price_impositions(equipment_id);

CREATE INDEX IF NOT EXISTS idx_equipment_price_impositions_model 
ON equipment_price_impositions(model_id);

CREATE INDEX IF NOT EXISTS idx_equipment_price_impositions_year 
ON equipment_price_impositions(year);

-- Trigger for updated_at
CREATE TRIGGER update_equipment_price_impositions_updated_at
BEFORE UPDATE ON equipment_price_impositions
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();