# MASTER PROMPT — BUILD DROPQR STUDIO FROM SCRATCH

Act as senior product architect, security-minded full-stack engineer and test lead. Build DROPQR Studio: a multi-tenant platform for shops to receive customer files by QR code and prepare images/documents using a document-processing studio.

This is a **clean rebuild**. Do not assume any source code, database schema, storage bucket or credentials from the previous Bolt project will be reused.

## Product experiences

### 1. Shop web workspace
Responsive Next.js application for owners and authorized employees:
- Overview and recent sessions
- QR station management
- Private file inbox
- Preview, categorize, rename display labels, download and delete authorized files
- Document Studio and processing history
- Shop settings and team management

### 2. Customer upload
Mobile-first page opened by scanning a shop QR:
- No customer account required
- Upload photographs, signatures and documents
- Progress, retry and clear completion/error states
- Isolated temporary session
- No access to other sessions, shop inboxes, file listings or downloads
- Do not require name/phone unless owner explicitly adds this requirement

### 3. Document Studio
Initial capabilities, only where implementation and tests support them:
- JPEG/JPG, PNG and WebP conversion
- Resize, crop, rotate and compress images
- Configurable photo/signature presets (not hard-coded to one portal)
- PDF merge, split, page reorder and rotate; compression only if reliable
- Batch processing, per-file progress, preview and output download
- Preserve original files; create separate output records
- Publish a format/support matrix and tested limits

Do not claim universal format support or guaranteed target file size.

## Principles
- Reliable receipt before visual polish.
- Prefer browser/local processing when practical; cloud processing is cost-aware.
- Web product remains useful without Windows helper.
- Multi-tenant from the beginning; first tenant is AK DIGITAL SERVICES.
- Do not build accounting, inventory, POS or e-commerce into this product.
- No unlimited storage promise.
- Do not promise 3 GB uploads at launch.

## Required stack
- Next.js App Router, TypeScript strict mode
- Supabase PostgreSQL, Auth and private Storage
- Vercel
- GitHub
- Monorepo preferred if it remains simple
- Later desktop: Tauri 2 + Rust

Choose compatible stable versions at implementation time, verify official docs, pin dependencies and commit lockfile. Use a modular monolith, not microservices without evidence.

## Multi-tenancy and roles
Roles: platform administrator, shop owner, and optionally shop manager/employee. A user may later belong to multiple shops. Use explicit membership records. Never authorize from user-editable profile metadata. Every tenant-owned row must include `shop_id`; validate membership and role on the server. Automated negative tests must prove Shop A cannot read, list, update, delete or download Shop B data or objects.

## Domain model to design before UI
Expected entities:
- profiles
- shops
- shop_memberships
- qr_stations
- upload_sessions
- files
- processing_jobs
- processing_outputs or a unified files table with parent/derivation relationship
- audit_logs
- retention_policies
- usage_records (later)
- desktop_devices (later)

Use UUID IDs, foreign keys, constraints, indexes and explicit state transitions. File metadata should include shop/session, parent file, opaque storage key, safe display name, detected MIME, extension, byte size, checksum if feasible, category, source, status and lifecycle timestamps. Never use customer-supplied filename as storage path.

## QR and upload security
- Permanent QR contains an opaque public station identifier, not a secret granting file access.
- Station can be disabled or rotated by authorized shop user.
- Create upload sessions through a server-authorized operation after validating active station.
- Use high-entropy unguessable session capability; store only token hash where practical.
- Token is session-scoped and upload-only.
- Enforce expiry, allowed types, file count, per-file size, total quota and rate limits.
- Customer cannot enumerate, preview, download or delete uploaded files through the anonymous capability.
- Do not leak tokens in logs, analytics, referrers or error reports.

## Storage and uploads
Use private Supabase Storage. Test storage policies independently of database RLS. Validate actual file signatures, not just extensions or browser MIME. Generate opaque object keys. Plan retry/resume, duplicate behavior, quotas, orphan cleanup, expiry cleanup and short-lived authorized downloads. Start with conservative configurable limits. Treat 3 GB as a future target requiring verified multipart/resumable upload, memory-safe processing, cost model and staged load tests.

## Processing architecture
Define a processing contract: operation ID/version, input file IDs, validated settings, processing location (browser/desktop/future server), status/progress, structured errors and output metadata. Use browser workers for supported operations. Avoid loading very large files entirely into memory. Revoke object URLs. Never mutate original. Each output is a separate file record linked to its source. Clearly distinguish local-only files from cloud-saved files.

## UX
Professional, restrained, minimal design; responsive shop workspace and mobile upload; accessible drag/drop alternatives; clear loading, empty, progress, success, error and offline states. Main navigation: Overview, File Inbox, Document Studio, QR Stations, Processing History, Team/Settings. Document Studio is a focused utility, not an accounting dashboard. Tangerine is workflow inspiration only; do not copy proprietary assets or branding.

## Authentication and privacy
Use current recommended Supabase/Next.js server-side session handling. All privileged operations verify auth, shop membership and role server-side. No service-role key in client bundles. Rate-limit public endpoints. Log sensitive actions without logging tokens or document contents. Define and disclose retention before production. A 24-hour upload-session expiry is only a proposed default, requiring owner approval. Deletion must cover DB metadata and storage objects with retryable cleanup. Database backups alone do not back up uploaded files; test both.

## Testing
Continuously add:
- Domain/unit tests
- Session and upload integration tests
- RLS tests for all tenant-owned tables
- Storage policy tests
- Cross-tenant negative tests
- End-to-end owner and customer QR flows
- Mobile/responsive and accessibility tests
- CI lint, strict typecheck, tests and production build

Never remove or weaken tests merely to get green CI.

## Environments and deployment
Use local development, Vercel previews and production. Separate Supabase staging and production where practical. Provide `.env.example` placeholders only. Document migrations, storage setup, auth redirects, Vercel variables, backups, restore and rollback. Never apply destructive production migrations without explicit approval and verified backup.

## Phases and gates

### Phase 0 — Plan only
Read all specs; identify ambiguity; propose repository structure, dependencies, schema, route map, security matrix, test strategy and acceptance criteria. No implementation. Ask for approval.

### Phase 1 — Foundation
Initialize Next.js, strict TS, lint, tests, CI, env validation, design tokens, Supabase integration; migrations for profiles/shops/memberships and RLS. Gate: build/tests pass and tenant-isolation tests pass.

### Phase 2 — QR and upload
QR station management, temporary sessions, mobile upload, private storage, validation, progress, inbox, expiry/cleanup. Gate: customer capability cannot list/download/delete; end-to-end and tenant tests pass.

### Phase 3 — File management
Safe preview, categorize, download, delete, filters, audit and retention. Gate: lifecycle and storage cleanup tests pass.

### Phase 4 — Document Studio
Image operations, configurable presets, reliable PDF operations, batch, progress and outputs. Gate: originals unchanged; representative browser tests pass; support matrix documented.

### Phase 5 — Production hardening
Roles, quotas, backup/restore, cleanup monitoring, security review, Android/weak-network tests, Vercel preview. Gate: release checklist approved.

### Phase 6 — Windows companion
Tauri 2 + Rust; secure pairing/revocation; local processing; drag/drop; shortcuts; optional Shift-triggered quick action. No backend secret in desktop app. Gate: installer, credentials, updates and revocation tested.

### Phase 7 — SaaS
Shop onboarding, platform administration, usage metering, plans and billing only after cost model, data export/deletion and support processes are validated.

Do not skip gates or represent scaffolding as completed functionality.

## Documentation deliverables
Maintain architecture decisions, schema/ERD, RLS/storage matrix, API contracts, processing support matrix, threat model, local setup, deployment/rollback, backup/restore, test plan and release checklist.

## First instruction
Do not code immediately. Read `AGENTS.md`, this prompt and all `docs/`. Summarize product constraints; identify missing decisions; propose exact repository structure, dependency choices, schema, tenant isolation, routes, test plan and Phase 0 acceptance criteria. Ask the user to approve Phase 1. Do not implement Phase 1 without explicit approval.
