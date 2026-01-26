-- Add missing columns to volumes table to support full specification
ALTER TABLE volumes 
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS category VARCHAR DEFAULT 'Inbound Operations',
ADD COLUMN IF NOT EXISTS unit_of_measure VARCHAR NOT NULL DEFAULT 'Units',
ADD COLUMN IF NOT EXISTS is_price_item BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN IF NOT EXISTS is_labor_driver BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS is_equipment_driver BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS is_provided BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS pricing_method VARCHAR NOT NULL DEFAULT 'Per Unit',
ADD COLUMN IF NOT EXISTS margin_type VARCHAR NOT NULL DEFAULT 'Percentage',
ADD COLUMN IF NOT EXISTS units_per_fte NUMERIC DEFAULT NULL,
ADD COLUMN IF NOT EXISTS auto_grow BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS annual_growth_rate NUMERIC DEFAULT NULL,
ADD COLUMN IF NOT EXISTS growth_pattern VARCHAR DEFAULT 'Linear',
ADD COLUMN IF NOT EXISTS row_order INTEGER NOT NULL DEFAULT 0;

-- Update the service_line column name to stream_name for consistency with spec
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'volumes' AND column_name = 'service_line') THEN
        ALTER TABLE volumes RENAME COLUMN service_line TO stream_name;
    END IF;
END $$;

-- Add constraints and indexes
ALTER TABLE volumes 
ADD CONSTRAINT volumes_growth_rate_check CHECK (annual_growth_rate IS NULL OR (annual_growth_rate >= -50 AND annual_growth_rate <= 100)),
ADD CONSTRAINT volumes_units_per_fte_check CHECK (units_per_fte IS NULL OR units_per_fte > 0);

CREATE INDEX IF NOT EXISTS idx_volumes_model_id_row_order ON volumes(model_id, row_order);
CREATE INDEX IF NOT EXISTS idx_volumes_category ON volumes(category);
CREATE INDEX IF NOT EXISTS idx_volumes_flags ON volumes(is_price_item, is_labor_driver, is_equipment_driver);

-- Update existing data with sensible defaults (category and unit_of_measure)
UPDATE volumes
SET
    category = CASE
        WHEN stream_name ILIKE '%inbound%' OR stream_name ILIKE '%receiv%' THEN 'Inbound Operations'
        WHEN stream_name ILIKE '%outbound%' OR stream_name ILIKE '%ship%' THEN 'Outbound Operations'
        WHEN stream_name ILIKE '%storage%' OR stream_name ILIKE '%warehous%' THEN 'Storage Services'
        WHEN stream_name ILIKE '%value%' OR stream_name ILIKE '%kit%' OR stream_name ILIKE '%label%' THEN 'Value-Added Services'
        ELSE 'Inbound Operations'
    END,
    unit_of_measure = CASE
        WHEN stream_name ILIKE '%pallet%' THEN 'Pallets'
        WHEN stream_name ILIKE '%hour%' OR stream_name ILIKE '%labor%' THEN 'Hours'
        WHEN stream_name ILIKE '%line%' OR stream_name ILIKE '%item%' THEN 'Lines'
        ELSE 'Units'
    END
WHERE category IS NULL OR unit_of_measure = 'Units';

-- Update row_order using a CTE (window functions can't be used directly in UPDATE)
WITH row_orders AS (
    SELECT id, (ROW_NUMBER() OVER (PARTITION BY model_id ORDER BY created_at)) * 10 as new_order
    FROM volumes
)
UPDATE volumes v
SET row_order = ro.new_order
FROM row_orders ro
WHERE v.id = ro.id AND v.row_order = 0;