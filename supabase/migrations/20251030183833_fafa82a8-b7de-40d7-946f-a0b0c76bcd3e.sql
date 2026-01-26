-- Create function to get states with city counts using explicit JOIN
CREATE OR REPLACE FUNCTION get_states_with_city_counts(p_country_code text DEFAULT NULL)
RETURNS TABLE (
  id uuid,
  country_code varchar,
  name varchar,
  code varchar,
  created_at timestamptz,
  country_name varchar,
  cities_count bigint,
  last_city_sync timestamptz
) 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.country_code,
    s.name,
    s.code,
    s.created_at,
    c.name as country_name,
    COUNT(ci.id)::bigint as cities_count,
    MAX(ci.created_at) as last_city_sync
  FROM states s
  LEFT JOIN countries c ON c.code = s.country_code
  LEFT JOIN cities ci ON ci.country_code = s.country_code AND ci.state = s.name
  WHERE (p_country_code IS NULL OR s.country_code = p_country_code)
  GROUP BY s.id, s.country_code, s.name, s.code, s.created_at, c.name
  ORDER BY s.name;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_states_with_city_counts TO authenticated;