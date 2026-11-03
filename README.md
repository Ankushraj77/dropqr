# DROPQR Studio

DROPQR Studio is a multi-tenant workspace for shops to receive customer files by QR code and prepare images and documents. This repository is a clean rebuild; it does not depend on the earlier Bolt project.

## Current status

Phase 1 foundation is in progress. The repository contains the Next.js web app shell, pinned npm workspace dependencies, Supabase SSR client wrappers, environment validation, a local Supabase configuration, and the initial tenant schema migration. Authentication, shop onboarding, QR upload, file storage, and processing are not connected yet; the current overview clearly shows an unconnected local preview.

## Stack

- Next.js App Router and TypeScript
- Supabase PostgreSQL, Auth, and private Storage
- Vercel deployment target
- npm workspaces and committed lockfile
- Tauri 2 + Rust only in a later desktop phase

## Local setup

Requirements: Node.js 24 and npm 11. The web app can start without Supabase credentials while the UI foundation is being built.

```powershell
npm ci
npm run dev
```

For Supabase local development, install Docker Desktop, then use the Supabase CLI:

```powershell
npx supabase start
```

Copy `apps/web/.env.example` to `apps/web/.env.local` and provide a development project URL and publishable key before adding any auth or database reads. Never add service-role keys or customer files to Git.

## Documentation

Read `AGENTS.md`, `MASTER_PROMPT.md`, and the files in `docs/` before making product or security changes. Schema changes belong in reviewed Supabase migrations. Do not apply migrations to a remote project or deploy to production without explicit approval and a recovery plan.
