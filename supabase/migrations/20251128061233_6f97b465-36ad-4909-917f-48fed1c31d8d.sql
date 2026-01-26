-- Add partial unique indexes for equipment sync upsert operations
-- These indexes only apply when equipment_id IS NOT NULL, allowing manual entries to remain flexible

-- Unique constraint for opex_lines: one equipment per model
CREATE UNIQUE INDEX IF NOT EXISTS idx_opex_lines_model_equipment 
ON opex_lines (model_id, equipment_id) 
WHERE equipment_id IS NOT NULL;

-- Unique constraint for capex_lines: one equipment per model
CREATE UNIQUE INDEX IF NOT EXISTS idx_capex_lines_model_equipment 
ON capex_lines (model_id, equipment_id) 
WHERE equipment_id IS NOT NULL;