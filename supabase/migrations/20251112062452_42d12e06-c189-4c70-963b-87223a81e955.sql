-- RETRY: Site Allocation Removal Migration
-- Force execution of all critical changes

-- 1. Drop trigger (with CASCADE to ensure removal)
DROP TRIGGER IF EXISTS opex_site_allocation_trigger ON opex_lines CASCADE;

-- 2. Drop trigger function (with CASCADE)
DROP FUNCTION IF EXISTS trigger_update_site_allocation() CASCADE;

-- 3. Update existing site allocation lines
UPDATE opex_lines 
SET 
    protected = false,
    description = 'Site Allocation (converted from auto-calculation - verify costs)',
    notes = COALESCE(notes || E'\n\n', '') || 
        '⚠️ IMPORTANT: Automatic site allocation discontinued 2025-01-12. ' ||
        'Converted to manual entry. Review and update costs as needed.'
WHERE is_site_allocation = true;