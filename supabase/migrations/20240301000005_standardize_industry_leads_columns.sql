-- Migration: Standardize industry_leads columns to be industry-agnostic
-- This renames patient-specific columns to generic lead columns
-- Date: 2024-03-01

-- Rename patient_name → lead_name
ALTER TABLE industry_leads RENAME COLUMN patient_name TO lead_name;

-- Rename patient_email → lead_email
ALTER TABLE industry_leads RENAME COLUMN patient_email TO lead_email;

-- Rename patient_phone → lead_phone
ALTER TABLE industry_leads RENAME COLUMN patient_phone TO lead_phone;

-- Update any RLS policies that reference the old column names
-- (This will be handled by the system automatically, but we'll verify)

-- Verify the changes
DO $$
DECLARE
    column_exists boolean;
BEGIN
    -- Check if lead_name exists
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'industry_leads' 
        AND column_name = 'lead_name'
    ) INTO column_exists;
    
    IF column_exists THEN
        RAISE NOTICE '✓ Column lead_name exists';
    ELSE
        RAISE NOTICE '✗ Column lead_name does NOT exist';
    END IF;
    
    -- Check if lead_email exists
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'industry_leads' 
        AND column_name = 'lead_email'
    ) INTO column_exists;
    
    IF column_exists THEN
        RAISE NOTICE '✓ Column lead_email exists';
    ELSE
        RAISE NOTICE '✗ Column lead_email does NOT exist';
    END IF;
    
    -- Check if lead_phone exists
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'industry_leads' 
        AND column_name = 'lead_phone'
    ) INTO column_exists;
    
    IF column_exists THEN
        RAISE NOTICE '✓ Column lead_phone exists';
    ELSE
        RAISE NOTICE '✗ Column lead_phone does NOT exist';
    END IF;
    
    -- Check if old columns are gone
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'industry_leads' 
        AND column_name = 'patient_name'
    ) INTO column_exists;
    
    IF NOT column_exists THEN
        RAISE NOTICE '✓ Old column patient_name removed';
    ELSE
        RAISE NOTICE '✗ Old column patient_name still exists';
    END IF;
END $$;