-- =============================================================================
-- Industry Leads Table
-- =============================================================================
-- Unified table for HVAC Pro, Plumb Pro, and Spark Pro lead submissions.
-- One table handles all 3 industries via the `industry` column.
--
-- Key design decisions:
--   - auth_user_id is NULLABLE: public submissions without operatorId use pool account
--   - account_id is NOT NULL: always set (operator account or pool account)
--   - RLS uses account_id (not auth_user_id) to handle NULL rows correctly
--   - Pool accounts are pre-seeded with fixed UUIDs for deterministic attribution
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Pool Accounts (pre-seeded, fixed UUIDs)
-- -----------------------------------------------------------------------------
-- These accounts capture leads submitted without an operatorId.
-- Safe to run multiple times due to ON CONFLICT DO NOTHING.

INSERT INTO public.accounts (id, name, slug, status, plan)
VALUES
  ('00000000-0000-0000-0001-000000000001', 'HVAC Pool',       'hvac-pool',       'active', 'pool'),
  ('00000000-0000-0000-0002-000000000002', 'Plumbing Pool',   'plumbing-pool',   'active', 'pool'),
  ('00000000-0000-0000-0003-000000000003', 'Electrical Pool', 'electrical-pool', 'active', 'pool')
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 2. Create industry_leads table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.industry_leads (
  id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Attribution
  account_id               UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  auth_user_id             UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  -- auth_user_id is NULLABLE: NULL = unattributed lead assigned to pool account

  industry                 TEXT NOT NULL,

  -- Contact Info
  customer_name            TEXT NOT NULL,
  customer_email           TEXT NOT NULL,
  customer_phone           TEXT NOT NULL,
  service_address          TEXT,
  city                     TEXT,
  state                    TEXT,
  zip_code                 TEXT,

  -- Service Request
  urgency                  TEXT NOT NULL DEFAULT 'scheduled',
  preferred_contact_method TEXT NOT NULL DEFAULT 'phone',
  preferred_time           TEXT,
  notes                    TEXT,

  -- Industry-specific data (flexible JSONB per industry)
  service_details          JSONB NOT NULL DEFAULT '{}',

  -- Status & Assignment
  status                   TEXT NOT NULL DEFAULT 'new',
  estimated_value          NUMERIC(10,2),
  assigned_to              TEXT,

  -- Timestamps
  submitted_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Constraints
  CONSTRAINT industry_leads_industry_check
    CHECK (industry IN ('hvac', 'plumbing', 'electrical')),

  CONSTRAINT industry_leads_status_check
    CHECK (status IN ('new', 'contacted', 'scheduled', 'completed', 'lost')),

  CONSTRAINT industry_leads_urgency_check
    CHECK (urgency IN ('emergency', 'urgent', 'scheduled', 'estimate_only')),

  CONSTRAINT industry_leads_contact_method_check
    CHECK (preferred_contact_method IN ('phone', 'email', 'text')),

  CONSTRAINT industry_leads_email_check
    CHECK (customer_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- -----------------------------------------------------------------------------
-- 3. Indexes
-- -----------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_industry_leads_account_id
  ON public.industry_leads(account_id);

CREATE INDEX IF NOT EXISTS idx_industry_leads_auth_user_id
  ON public.industry_leads(auth_user_id);

CREATE INDEX IF NOT EXISTS idx_industry_leads_industry
  ON public.industry_leads(industry);

CREATE INDEX IF NOT EXISTS idx_industry_leads_status
  ON public.industry_leads(status);

CREATE INDEX IF NOT EXISTS idx_industry_leads_urgency
  ON public.industry_leads(urgency);

CREATE INDEX IF NOT EXISTS idx_industry_leads_submitted_at
  ON public.industry_leads(submitted_at DESC);

-- Composite: most common dashboard query (account + industry + status)
CREATE INDEX IF NOT EXISTS idx_industry_leads_account_industry_status
  ON public.industry_leads(account_id, industry, status);

-- -----------------------------------------------------------------------------
-- 4. updated_at trigger
-- -----------------------------------------------------------------------------
-- Reuses the existing handle_updated_at() function already in the database.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'handle_industry_leads_updated_at'
      AND tgrelid = 'public.industry_leads'::regclass
  ) THEN
    CREATE TRIGGER handle_industry_leads_updated_at
      BEFORE UPDATE ON public.industry_leads
      FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
  END IF;
END $$;

-- -----------------------------------------------------------------------------
-- 5. Row Level Security
-- -----------------------------------------------------------------------------

ALTER TABLE public.industry_leads ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if re-running
DROP POLICY IF EXISTS "Operators can view account leads"   ON public.industry_leads;
DROP POLICY IF EXISTS "Operators can manage account leads" ON public.industry_leads;
DROP POLICY IF EXISTS "Public can submit leads"            ON public.industry_leads;

-- Authenticated operators: view all leads for their account
-- Uses account_id (NOT auth_user_id) so NULL auth_user_id rows are visible
CREATE POLICY "Operators can view account leads"
  ON public.industry_leads
  FOR SELECT
  TO authenticated
  USING (account_id = get_current_user_account_id());

-- Authenticated operators: insert/update/delete leads for their account
CREATE POLICY "Operators can manage account leads"
  ON public.industry_leads
  FOR ALL
  TO authenticated
  USING (account_id = get_current_user_account_id())
  WITH CHECK (account_id = get_current_user_account_id());

-- Anonymous public: INSERT only (lead form submissions, no auth required)
CREATE POLICY "Public can submit leads"
  ON public.industry_leads
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- -----------------------------------------------------------------------------
-- 6. Verification queries (run after migration to confirm success)
-- -----------------------------------------------------------------------------
-- SELECT COUNT(*) FROM public.industry_leads;
-- SELECT id, name, slug FROM public.accounts WHERE slug IN ('hvac-pool', 'plumbing-pool', 'electrical-pool');
-- SELECT schemaname, tablename, rowsecurity FROM pg_tables WHERE tablename = 'industry_leads';
-- SELECT policyname, cmd, roles FROM pg_policies WHERE tablename = 'industry_leads';