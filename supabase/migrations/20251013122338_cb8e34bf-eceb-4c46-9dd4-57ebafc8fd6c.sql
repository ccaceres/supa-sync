-- Add pricing permissions to the permission_type enum
ALTER TYPE permission_type ADD VALUE IF NOT EXISTS 'pricing.view';
ALTER TYPE permission_type ADD VALUE IF NOT EXISTS 'pricing.create';
ALTER TYPE permission_type ADD VALUE IF NOT EXISTS 'pricing.edit';
ALTER TYPE permission_type ADD VALUE IF NOT EXISTS 'pricing.delete';