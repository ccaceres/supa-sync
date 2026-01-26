-- Force recalculation of all CAPEX depreciation values with new logic
UPDATE capex_lines SET updated_at = NOW();