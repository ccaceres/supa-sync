-- Update cities to use matching country codes from countries table
UPDATE public.cities 
SET country_code = CASE 
  WHEN country_code = 'US' THEN 'USA'
  WHEN country_code = 'CA' THEN 'CAN'
  WHEN country_code = 'GB' THEN 'GBR'
  WHEN country_code = 'DE' THEN 'DEU'
  WHEN country_code = 'FR' THEN 'FRA'
  WHEN country_code = 'AU' THEN 'AUS'
  WHEN country_code = 'JP' THEN 'JPN'
  WHEN country_code = 'BR' THEN 'BRA'
  WHEN country_code = 'IN' THEN 'IND'
  WHEN country_code = 'CN' THEN 'CHN'
  ELSE country_code
END;