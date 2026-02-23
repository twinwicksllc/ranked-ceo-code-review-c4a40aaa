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
- [ ] Phase B: HVAC Pro
- [ ] Phase C: Plumb Pro
- [ ] Phase D: Spark Pro
- [ ] Phase E: Database & DNS