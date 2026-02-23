-- 1. CLEAN SLATE
-- This removes all conflicting policies, triggers, and the table itself
DROP TABLE IF EXISTS public.smile_assessments CASCADE;

-- 2. CREATE CONSOLIDATED TABLE
-- All columns defined with correct types (arrays for goals/conditions)
CREATE TABLE public.smile_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    
    -- Identity & Linking (Nullable for public intake)
    account_id UUID NOT NULL REFERENCES public.accounts(id),
    auth_user_id UUID REFERENCES auth.users(id),
    
    -- Patient Data
    patient_name TEXT,
    patient_email TEXT,
    patient_phone TEXT,
    patient_dob DATE,
    
    -- Clinical Data (Correct Array Types)
    smile_goals TEXT[] DEFAULT '{}',
    medical_conditions TEXT[] DEFAULT '{}',
    current_concerns TEXT,
    pain_sensitivity TEXT,
    desired_outcome TEXT,
    
    -- Dental History
    dentist_name TEXT,
    last_dental_visit TEXT,
    dental_insurance BOOLEAN DEFAULT false,
    insurance_provider TEXT,
    
    -- Health Data
    medications TEXT,
    allergies TEXT,
    
    -- Metadata
    status TEXT DEFAULT 'pending'
);

-- 3. HIPAA-HARDENED SECURITY (RLS)
ALTER TABLE public.smile_assessments ENABLE ROW LEVEL SECURITY;

-- POLICY A: BLIND INSERT (Public Intake)
-- Allows the anon role to "Write-Only" to the Pool Account
CREATE POLICY "Public intake blind insert"
ON public.smile_assessments FOR INSERT TO anon
WITH CHECK (account_id = '00000000-0000-4000-a000-000000000004');

-- POLICY B: FULL ACCESS (Staff/Dentists)
-- Allows authenticated users to see only their account's data
CREATE POLICY "Staff account isolation"
ON public.smile_assessments FOR ALL TO authenticated
USING (account_id = (SELECT account_id FROM public.users WHERE auth_user_id = auth.uid() LIMIT 1));

-- 4. SYSTEM PERMISSIONS (The "42501" Fixes)
GRANT USAGE ON SCHEMA public TO anon;
GRANT INSERT ON public.smile_assessments TO anon;
-- Granting SELECT on accounts is required for the Foreign Key check to pass
GRANT SELECT ON public.accounts TO anon;

-- 5. TRIGGER SECURITY
-- Ensure the timestamp trigger runs with system power
CREATE OR REPLACE FUNCTION public.handle_updated_at() 
RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$ 
LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_smile_assessment_updated
    BEFORE UPDATE ON public.smile_assessments
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 6. PERFORMANCE INDEXES
CREATE INDEX idx_smile_assessments_account_id ON public.smile_assessments(account_id);
CREATE INDEX idx_smile_assessments_auth_user_id ON public.smile_assessments(auth_user_id);
CREATE INDEX idx_smile_assessments_status ON public.smile_assessments(status);
CREATE INDEX idx_smile_assessments_created_at ON public.smile_assessments(created_at DESC);