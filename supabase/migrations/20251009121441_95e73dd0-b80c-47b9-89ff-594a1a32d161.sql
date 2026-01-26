-- Drop existing library_schedules table and recreate with simplified structure
DROP TABLE IF EXISTS public.library_schedules CASCADE;

-- Create simplified library_schedules table
CREATE TABLE public.library_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR NOT NULL,
    paid_days_per_year NUMERIC NOT NULL DEFAULT 260,
    paid_holidays_per_year NUMERIC NOT NULL DEFAULT 10,
    paid_pto_days_per_year NUMERIC NOT NULL DEFAULT 15,
    paid_hours_per_day NUMERIC NOT NULL DEFAULT 8,
    paid_break_hours_per_day NUMERIC NOT NULL DEFAULT 0.5,
    is_active BOOLEAN NOT NULL DEFAULT true,
    description TEXT,
    created_by UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.library_schedules ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Authenticated users with library view permission can see schedules"
    ON public.library_schedules
    FOR SELECT
    USING (has_permission(auth.uid(), 'library.view'::permission_type));

CREATE POLICY "Users can create library schedules"
    ON public.library_schedules
    FOR INSERT
    WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update library schedules they created"
    ON public.library_schedules
    FOR UPDATE
    USING (auth.uid() = created_by);

CREATE POLICY "Users can delete library schedules they created"
    ON public.library_schedules
    FOR DELETE
    USING (auth.uid() = created_by);

-- Trigger for updated_at
CREATE TRIGGER update_library_schedules_updated_at
    BEFORE UPDATE ON public.library_schedules
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Update system settings for schedule visible fields
UPDATE public.system_settings
SET setting_value = '["name", "paid_days_per_year", "paid_holidays_per_year", "paid_pto_days_per_year", "paid_hours_per_day", "paid_break_hours_per_day", "description"]'::jsonb
WHERE setting_key = 'schedule_visible_fields';