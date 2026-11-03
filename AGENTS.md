# Codex Instructions — DROPQR Studio

Read `MASTER_PROMPT.md` and every file in `docs/` before changing code.

## Rules
- Start with Phase 0 only: inspect specs, identify ambiguity, propose plan; do not code until user approves Phase 1.
- Build incrementally; use small, reviewable changes and feature branches.
- Never invent credentials, project IDs, secrets, URLs, test results, or completed functionality.
- No destructive database changes or production deployment without explicit approval and verified recovery point.
- Never commit secrets, `.env`, customer files, database dumps, signing keys, or service-role credentials.
- Pin dependencies and commit lockfiles.
- Verify current official Next.js, Supabase, Vercel and Tauri documentation before version-sensitive implementation.
- Use reviewed Supabase migrations as schema source of truth.
- Add tests with features. Run lint, strict typecheck, tests and build after meaningful changes.
- Do not weaken tests to make CI green.

## Architecture and security
- Modular monolith; multi-tenant from the first migration.
- Every tenant-owned record has `shop_id`; verify membership server-side.
- RLS on every exposed tenant-owned table; test cross-tenant denial.
- Private storage only; object paths are not authorization.
- Customer upload capabilities are high-entropy, temporary, session-scoped and upload-only.
- Permanent QR identifies an upload station; it never grants access to existing files.
- Preserve originals; processing creates separate outputs.
- No service-role/secret key in browser or desktop clients.
- Windows companion is optional and later; it shares backend contracts and authorization.

A feature is done only when acceptance criteria, authorization, tests, error states, accessibility, docs, lint, typecheck and build are addressed. Report limitations honestly.
