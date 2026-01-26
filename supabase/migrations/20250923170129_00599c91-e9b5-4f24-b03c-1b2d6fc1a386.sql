-- Add HR-specific permissions to existing permission_type enum  
ALTER TYPE permission_type ADD VALUE IF NOT EXISTS 'labor_requests.approve';
ALTER TYPE permission_type ADD VALUE IF NOT EXISTS 'labor_requests.manage';
ALTER TYPE permission_type ADD VALUE IF NOT EXISTS 'hr.view_all_requests';