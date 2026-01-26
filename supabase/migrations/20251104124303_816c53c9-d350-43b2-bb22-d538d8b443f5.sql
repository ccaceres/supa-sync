-- Fix P&L navigation URL to use correct template syntax
UPDATE navigation_items 
SET url = '/projects/{projectId}/rounds/{roundId}/models/{modelId}/pnl'
WHERE url = '/projects/:projectId/rounds/:roundId/models/:modelId/pnl';