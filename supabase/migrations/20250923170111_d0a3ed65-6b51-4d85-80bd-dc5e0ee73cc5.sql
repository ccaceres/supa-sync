-- Add HR role to existing app_role enum (separate transaction)
ALTER TYPE app_role ADD VALUE IF NOT EXISTS 'hr_lead';