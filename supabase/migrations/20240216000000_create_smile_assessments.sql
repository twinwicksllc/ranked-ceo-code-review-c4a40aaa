-- 1. Create the helper function for timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Create the table with the required HIPAA security column
-- Using auth_user_id to match existing schema
CREATE TABLE IF NOT EXISTS public.smile_assessments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    account_id UUID REFERENCES public.accounts(id) ON DELETE CASCADE NOT NULL,
    auth_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    patient_name TEXT NOT NULL,
    patient_email TEXT NOT NULL,
    patient_phone TEXT,
    patient_dob DATE,
    dentist_name TEXT,
    last_dental_visit TEXT,
    dental_insurance BOOLEAN DEFAULT false,
    insurance_provider TEXT,
    current_concerns TEXT,
    pain_sensitivity TEXT,
    smile_goals TEXT[],
    desired_outcome TEXT,
    medical_conditions TEXT[],
    medications TEXT,
    allergies TEXT,
    status TEXT DEFAULT 'pending'
);

-- 3. If user_id column exists (from previous failed migration), drop it and add auth_user_id
DO $$
BEGIN
    -- Drop user_id column if it exists
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'smile_assessments' 
        AND column_name = 'user_id'
    ) THEN
        ALTER TABLE public.smile_assessments DROP COLUMN user_id;
    END IF;
    
    -- Add auth_user_id if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'smile_assessments' 
        AND column_name = 'auth_user_id'
    ) THEN
        ALTER TABLE public.smile_assessments ADD COLUMN auth_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL;
    END IF;
END $$;

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.smile_assessments ENABLE ROW LEVEL SECURITY;

-- 5. Create Security Policies using auth_user_id
-- Allow authenticated dentists to view their own assessments
DROP POLICY IF EXISTS "Dentists can view their own assessments" ON public.smile_assessments;
CREATE POLICY "Dentists can view their own assessments" 
ON public.smile_assessments
FOR SELECT
TO authenticated
USING (auth.uid() = auth_user_id);

-- Allow authenticated dentists to update their own assessments
DROP POLICY IF EXISTS "Dentists can update their own assessments" ON public.smile_assessments;
CREATE POLICY "Dentists can update their own assessments" 
ON public.smile_assessments
FOR UPDATE
TO authenticated
USING (auth.uid() = auth_user_id);

-- Allow authenticated dentists to delete their own assessments
DROP POLICY IF EXISTS "Dentists can delete their own assessments" ON public.smile_assessments;
CREATE POLICY "Dentists can delete their own assessments" 
ON public.smile_assessments
FOR DELETE
TO authenticated
USING (auth.uid() = auth_user_id);

-- Allow public (unauthenticated) insert for patient submissions
DROP POLICY IF EXISTS "Allow public insert for patient assessments" ON public.smile_assessments;
CREATE POLICY "Allow public insert for patient assessments"
ON public.smile_assessments
FOR INSERT
TO public
WITH CHECK (true);

-- 6. Set up the auto-update trigger
DROP TRIGGER IF EXISTS on_smile_assessments_updated ON public.smile_assessments;
CREATE TRIGGER on_smile_assessments_updated
    BEFORE UPDATE ON public.smile_assessments
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 7. Add Documentation
COMMENT ON TABLE public.smile_assessments IS 'Stores patient assessment intake forms. Protected by RLS for HIPAA compliance.';