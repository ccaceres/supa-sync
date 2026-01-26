-- Add new column for proper foreign key relationship to price_lines
ALTER TABLE dl_roles 
ADD COLUMN IF NOT EXISTS price_line_id UUID REFERENCES price_lines(id) ON DELETE SET NULL;

-- Add similar column for indirect labor
ALTER TABLE labex_indirect_labor
ADD COLUMN IF NOT EXISTS price_line_id UUID REFERENCES price_lines(id) ON DELETE SET NULL;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_dl_roles_price_line_id ON dl_roles(price_line_id);
CREATE INDEX IF NOT EXISTS idx_labex_indirect_labor_price_line_id ON labex_indirect_labor(price_line_id);

-- Note: We keep price_line_imposition for backward compatibility
-- New functionality will use price_line_id