# Industry Templates — Phase A: Shared Infrastructure

## Status: IN PROGRESS

### Phase A Tasks
- [x] A1: lib/types/industry-lead.ts — TypeScript types
- [x] A2: lib/validations/industry-lead.ts — Zod schemas
- [x] A3: lib/data/pool-accounts.ts — Pool account UUID constants
- [x] A4: lib/data/industry-scripts.ts — NEBP scripts (backend only)
- [x] A5: lib/actions/industry-lead.ts — Server actions (submit, fetch, update)
- [x] A6: supabase/migrations/20240222000000_create_industry_leads.sql — DB migration
- [x] A7: components/industry/lead-form-shell.tsx — Shared non-HIPAA form wrapper
- [x] A8: components/industry/lead-card.tsx — Lead card component
- [x] A9: components/industry/lead-status-badge.tsx — Status badge
- [x] A10: components/industry/urgency-badge.tsx — Urgency badge
- [x] A11: components/industry/lead-filters.tsx — Filter bar
- [x] A12: components/industry/dashboard-stats.tsx — Stats cards
- [x] A13: middleware.ts — Updated with industry isolation + 3 new subdomains
- [x] A14: Build verification — npm run build passes ✅ (67 routes)

### Upcoming Phases
- [x] Phase B: HVAC Pro
  - [x] B1: components/hvac/hvac-lead-form.tsx — 5-step HVAC form
  - [x] B2: app/hvac/layout.tsx — subdomain guard + blue branding
  - [x] B3: app/hvac/(auth)/signup/page.tsx — HVAC signup with industry metadata
  - [x] B4: app/hvac/(auth)/login/page.tsx — HVAC login
  - [x] B5: app/hvac/page.tsx — protected dashboard
  - [x] B6: app/hvac/hvac-dashboard.tsx — operator dashboard client component
  - [x] B7: app/hvac/lead/page.tsx — public lead form
  - [x] B8: app/hvac/lead/success/page.tsx — confirmation page
  - [x] B9: Build verified ✅ (69 routes)
- [x] Phase C: Plumb Pro ✅ (5 routes)
- [x] Phase D: Spark Pro ✅ (5 routes)
- [ ] Phase E: Database & DNS
  - [ ] E1: Run migration in Supabase SQL Editor
  - [ ] E2: Add 3 custom domains in Vercel
  - [ ] E3: Add 3 CNAME records in GoDaddy
  - [ ] E4: Test all 3 subdomains end-to-end