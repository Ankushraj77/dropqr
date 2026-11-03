# Implementation Roadmap and Acceptance Gates

## Phase 0 — Plan
Deliver architecture proposal, schema proposal, routes, security matrix, test strategy and unresolved decisions. No implementation.

## Phase 1 — Foundation
Acceptance:
- App boots locally.
- Strict TypeScript, lint, tests and build pass.
- Supabase environment validation works.
- Initial schema and RLS are reviewed.
- Cross-tenant tests prove isolation.

## Phase 2 — QR and upload
Acceptance:
- Owner creates and disables QR station.
- Customer uploads without account.
- Session token cannot list/download/delete.
- Upload limits and expiration work.
- Shop inbox only sees its own sessions.

## Phase 3 — File management
Acceptance:
- Safe preview for supported formats.
- Download authorization is enforced.
- Delete removes object and metadata or queues a retryable cleanup.
- Audit events are generated.

## Phase 4 — Document Studio
Acceptance:
- Each supported operation has tests.
- Original remains unchanged.
- Output is a separate record.
- Batch failures do not corrupt successful outputs.
- Supported formats and tested limits are documented.

## Phase 5 — Production readiness
Acceptance:
- Security review complete.
- Tenant isolation and storage tests pass.
- Backup/restore tested.
- Mobile and weak-network tests pass.
- Vercel preview verified.
- Production approval obtained.

## Phase 6 — Windows companion
Acceptance:
- Secure pairing and revocation.
- Local processing and export.
- No backend secret in desktop bundle.
- Installer and update process documented.
- Desktop and web contracts remain compatible.

## Phase 7 — SaaS
Acceptance:
- Shop onboarding.
- Usage metering and quotas.
- Pricing validated against real storage/bandwidth costs.
- Billing and cancellation lifecycle tested.
- Data export and deletion workflows documented.
