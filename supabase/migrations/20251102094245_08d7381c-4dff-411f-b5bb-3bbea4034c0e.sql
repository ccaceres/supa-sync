-- Rename existing LABEX validation table to cost model validation
ALTER TABLE labex_validation_references RENAME TO cost_model_validation_references;

-- Add new columns for all cost categories
ALTER TABLE cost_model_validation_references
ADD COLUMN reference_capex NUMERIC(15, 2),
ADD COLUMN reference_impex NUMERIC(15, 2),
ADD COLUMN reference_opex_y1 NUMERIC(15, 2),
ADD COLUMN reference_equipment NUMERIC(15, 2),
ADD COLUMN reference_labex_indirect NUMERIC(15, 2),
ADD COLUMN reference_indirect_fte NUMERIC(10, 2),
ADD COLUMN reference_total_labex NUMERIC(15, 2);

-- Make existing LABEX columns optional (they might not always be provided)
ALTER TABLE cost_model_validation_references
ALTER COLUMN reference_labex_direct DROP NOT NULL,
ALTER COLUMN reference_direct_fte_input DROP NOT NULL,
ALTER COLUMN reference_direct_fte_calc DROP NOT NULL;

-- Update comments
COMMENT ON TABLE cost_model_validation_references IS 'Stores reference values from legacy systems (e.g., Zulu 1) for comprehensive cost model validation across all cost categories';
COMMENT ON COLUMN cost_model_validation_references.reference_capex IS 'Reference CAPEX value from legacy system';
COMMENT ON COLUMN cost_model_validation_references.reference_impex IS 'Reference IMPEX value from legacy system';
COMMENT ON COLUMN cost_model_validation_references.reference_opex_y1 IS 'Reference OPEX Year 1 value from legacy system';
COMMENT ON COLUMN cost_model_validation_references.reference_equipment IS 'Reference Equipment cost from legacy system';
COMMENT ON COLUMN cost_model_validation_references.reference_labex_indirect IS 'Reference indirect labor cost from legacy system';
COMMENT ON COLUMN cost_model_validation_references.reference_indirect_fte IS 'Reference indirect FTE count from legacy system';
COMMENT ON COLUMN cost_model_validation_references.reference_total_labex IS 'Reference total LABEX (direct + indirect) from legacy system';