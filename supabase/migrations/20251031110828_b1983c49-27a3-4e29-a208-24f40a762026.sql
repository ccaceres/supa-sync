-- Add override columns for manual investment year edits
ALTER TABLE capex_lines
  ADD COLUMN IF NOT EXISTS investment_override_year_1 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_2 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_3 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_4 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_5 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_6 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_7 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_8 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_9 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_10 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_11 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_12 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_13 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_14 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_15 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_16 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_17 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_18 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_19 NUMERIC DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS investment_override_year_20 NUMERIC DEFAULT NULL;

COMMENT ON COLUMN capex_lines.investment_override_year_1 IS 'Manual override for investment in year 1. NULL = use calculated value based on investment_year field.';

-- Update the investment years trigger to respect manual overrides
CREATE OR REPLACE FUNCTION update_capex_investment_years()
RETURNS TRIGGER AS $$
BEGIN
  -- For each year, check if there's an override. If yes, use it. If no, use calculated value.
  
  -- Year 1
  IF NEW.investment_override_year_1 IS NULL THEN
    NEW.investment_year_1 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 1 
                                   THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_1 := NEW.investment_override_year_1;
  END IF;
  
  -- Year 2
  IF NEW.investment_override_year_2 IS NULL THEN
    NEW.investment_year_2 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 2 
                                   THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_2 := NEW.investment_override_year_2;
  END IF;
  
  -- Year 3
  IF NEW.investment_override_year_3 IS NULL THEN
    NEW.investment_year_3 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 3 
                                   THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_3 := NEW.investment_override_year_3;
  END IF;
  
  -- Year 4
  IF NEW.investment_override_year_4 IS NULL THEN
    NEW.investment_year_4 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 4 
                                   THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_4 := NEW.investment_override_year_4;
  END IF;
  
  -- Year 5
  IF NEW.investment_override_year_5 IS NULL THEN
    NEW.investment_year_5 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 5 
                                   THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_5 := NEW.investment_override_year_5;
  END IF;
  
  -- Year 6
  IF NEW.investment_override_year_6 IS NULL THEN
    NEW.investment_year_6 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 6 
                                   THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_6 := NEW.investment_override_year_6;
  END IF;
  
  -- Year 7
  IF NEW.investment_override_year_7 IS NULL THEN
    NEW.investment_year_7 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 7 
                                   THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_7 := NEW.investment_override_year_7;
  END IF;
  
  -- Year 8
  IF NEW.investment_override_year_8 IS NULL THEN
    NEW.investment_year_8 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 8 
                                   THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_8 := NEW.investment_override_year_8;
  END IF;
  
  -- Year 9
  IF NEW.investment_override_year_9 IS NULL THEN
    NEW.investment_year_9 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 9 
                                   THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_9 := NEW.investment_override_year_9;
  END IF;
  
  -- Year 10
  IF NEW.investment_override_year_10 IS NULL THEN
    NEW.investment_year_10 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 10 
                                    THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_10 := NEW.investment_override_year_10;
  END IF;
  
  -- Year 11
  IF NEW.investment_override_year_11 IS NULL THEN
    NEW.investment_year_11 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 11 
                                    THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_11 := NEW.investment_override_year_11;
  END IF;
  
  -- Year 12
  IF NEW.investment_override_year_12 IS NULL THEN
    NEW.investment_year_12 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 12 
                                    THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_12 := NEW.investment_override_year_12;
  END IF;
  
  -- Year 13
  IF NEW.investment_override_year_13 IS NULL THEN
    NEW.investment_year_13 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 13 
                                    THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_13 := NEW.investment_override_year_13;
  END IF;
  
  -- Year 14
  IF NEW.investment_override_year_14 IS NULL THEN
    NEW.investment_year_14 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 14 
                                    THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_14 := NEW.investment_override_year_14;
  END IF;
  
  -- Year 15
  IF NEW.investment_override_year_15 IS NULL THEN
    NEW.investment_year_15 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 15 
                                    THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_15 := NEW.investment_override_year_15;
  END IF;
  
  -- Year 16
  IF NEW.investment_override_year_16 IS NULL THEN
    NEW.investment_year_16 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 16 
                                    THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_16 := NEW.investment_override_year_16;
  END IF;
  
  -- Year 17
  IF NEW.investment_override_year_17 IS NULL THEN
    NEW.investment_year_17 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 17 
                                    THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_17 := NEW.investment_override_year_17;
  END IF;
  
  -- Year 18
  IF NEW.investment_override_year_18 IS NULL THEN
    NEW.investment_year_18 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 18 
                                    THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_18 := NEW.investment_override_year_18;
  END IF;
  
  -- Year 19
  IF NEW.investment_override_year_19 IS NULL THEN
    NEW.investment_year_19 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 19 
                                    THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_19 := NEW.investment_override_year_19;
  END IF;
  
  -- Year 20
  IF NEW.investment_override_year_20 IS NULL THEN
    NEW.investment_year_20 := CASE WHEN GREATEST(COALESCE(NEW.investment_year, 1), 1) = 20 
                                    THEN COALESCE(NEW.total_investment, 0) ELSE 0 END;
  ELSE
    NEW.investment_year_20 := NEW.investment_override_year_20;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;