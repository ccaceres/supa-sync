-- Update route patterns from /equipment to /labex for existing alerts
UPDATE page_alerts_config 
SET route_pattern = '/projects/{projectId}/rounds/{roundId}/models/{modelId}/labex',
    updated_at = now()
WHERE route_pattern = '/projects/{projectId}/rounds/{roundId}/models/{modelId}/equipment';