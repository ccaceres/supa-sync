-- Create company-assets storage bucket for branding
INSERT INTO storage.buckets (id, name, public)
VALUES ('company-assets', 'company-assets', true)
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users with admin role to upload/update/delete
CREATE POLICY "Admins can upload company assets"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'company-assets' 
  AND public.has_role(auth.uid(), 'admin'::app_role)
);

CREATE POLICY "Admins can update company assets"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'company-assets' 
  AND public.has_role(auth.uid(), 'admin'::app_role)
);

CREATE POLICY "Admins can delete company assets"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'company-assets' 
  AND public.has_role(auth.uid(), 'admin'::app_role)
);

-- Anyone can view company assets (public bucket)
CREATE POLICY "Anyone can view company assets"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'company-assets');

-- Add company_logo_url setting to system_settings
INSERT INTO system_settings (setting_key, setting_value, category, description, data_type, is_public, validation_rules)
VALUES (
  'company_logo_url',
  'null',
  'ui',
  'URL of the company logo displayed in the header',
  'string',
  true,
  '{}'::jsonb
)
ON CONFLICT (setting_key) DO NOTHING;