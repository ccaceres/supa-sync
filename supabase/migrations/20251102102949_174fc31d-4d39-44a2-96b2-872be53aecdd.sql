-- Remove LABEX Validation navigation item
DELETE FROM navigation_items 
WHERE label = 'LABEX Validation' 
AND url LIKE '%/labex-validation';