# DROPQR Studio — Codex Blueprint

This is a specification package, not the application implementation. It defines a clean rebuild of DROPQR combined with a Tangerine-inspired document studio.

**Stack:** Next.js App Router + TypeScript, Supabase (PostgreSQL/Auth/private Storage), Vercel, GitHub. A Windows companion using Tauri 2 + Rust is a later phase.

## Start
1. Create a new private GitHub repository named `dropqr-studio`.
2. Extract this ZIP and upload its contents to the repository root. Do not upload the ZIP itself.
3. Connect the repository to Codex.
4. Ask Codex to read `AGENTS.md`, `MASTER_PROMPT.md`, and all `docs/`.
5. Ask it to perform Phase 0 only and present a plan. Approve Phase 1 separately.

No Bolt source code is assumed or required. Never commit secrets, `.env` files, service-role keys, database passwords, or customer documents.
