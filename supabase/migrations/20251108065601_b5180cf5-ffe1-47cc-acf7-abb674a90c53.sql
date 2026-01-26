-- IMPEX Simplification: Consolidate Charging Strategy into Recovery Configuration
-- This migration deprecates the old "Charging Strategy" fields in favor of "Recovery Configuration"
-- matching the CAPEX pattern for consistency and simplicity.

-- Add comments to deprecated columns
COMMENT ON COLUMN public.impex_lines.charging_method IS 'DEPRECATED: Use recovery_method instead. Kept for backward compatibility.';
COMMENT ON COLUMN public.impex_lines.depreciation_years IS 'DEPRECATED: Use num_amortization_months instead. Kept for backward compatibility.';
COMMENT ON COLUMN public.impex_lines.charging_treatment IS 'DEPRECATED: Treatment logic now handled by recovery configuration. Kept for backward compatibility.';
COMMENT ON COLUMN public.impex_lines.margin_markup IS 'DEPRECATED: Use upfront_markup instead. Kept for backward compatibility.';
COMMENT ON COLUMN public.impex_lines.cost_imposition IS 'DEPRECATED: Not used in new recovery configuration. Kept for backward compatibility.';

-- Migrate existing data: Copy charging strategy values to recovery configuration if recovery fields are null/default
UPDATE public.impex_lines
SET 
  recovery_method = CASE 
    WHEN charging_method = 'upfront' THEN 'upfront'::text
    WHEN charging_method = 'amortise' THEN 'amortized'::text
    ELSE recovery_method
  END,
  upfront_markup = COALESCE(upfront_markup, CASE 
    WHEN charging_method = 'upfront' AND margin_markup IS NOT NULL THEN 
      -- Convert margin to markup if treatment was margin (0), otherwise use as-is
      CASE 
        WHEN charging_treatment = 0 THEN (margin_markup / (100 - margin_markup)) * 100
        ELSE margin_markup
      END
    ELSE upfront_markup
  END),
  num_amortization_months = COALESCE(NULLIF(num_amortization_months, 0), CASE 
    WHEN charging_method = 'amortise' AND depreciation_years IS NOT NULL 
    THEN depreciation_years * 12
    ELSE num_amortization_months
  END)
WHERE 
  (recovery_method IS NULL OR recovery_method = 'upfront')
  AND (charging_method IS NOT NULL OR depreciation_years IS NOT NULL OR margin_markup IS NOT NULL);

-- Log migration completion
DO $$
BEGIN
  RAISE NOTICE 'IMPEX Charging Strategy consolidation completed. Old fields deprecated but preserved for backward compatibility.';
END $$;
