-- Grant projects.create permission to manager role
INSERT INTO role_permissions (role, permission)
VALUES ('manager', 'projects.create')
ON CONFLICT DO NOTHING;