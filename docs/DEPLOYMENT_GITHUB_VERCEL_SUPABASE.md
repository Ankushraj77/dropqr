# GitHub, Supabase and Vercel Setup

## GitHub
1. Create a new private repository named `dropqr-studio`.
2. Upload/extract the contents of this blueprint into the repository root.
3. Ensure `AGENTS.md`, `MASTER_PROMPT.md`, `README.md`, and `docs/` are at the root.
4. Do not upload `.env` files, secrets, customer files, or database dumps.
5. Connect the repository to Codex.

## Supabase
1. Create a development/staging Supabase project first.
2. Save project URL and publishable key in local environment configuration.
3. Keep service-role/secret keys server-only and out of Git.
4. Create and review migrations locally.
5. Enable RLS and test policies before exposing tables.
6. Create private storage buckets and test object access policies.
7. Keep production separate from development where practical.

## Vercel
1. Import the GitHub repository into Vercel.
2. Set the correct web app root directory if a monorepo is used.
3. Configure environment variables separately for Preview and Production.
4. Deploy Preview first.
5. Verify auth redirects, upload flows, storage permissions and server logs.
6. Promote to Production only after the release gate passes.

## Environment file
Codex should create `.env.example` with placeholder names only. The real `.env.local` must be ignored by Git.

Potential variables (confirm exact names during implementation):
- NEXT_PUBLIC_SUPABASE_URL
- NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY (or current official equivalent)
- SUPABASE_SECRET_KEY (server-only, only if truly needed)

Do not assume legacy key names or APIs without checking current Supabase documentation.

## Production safety
Never run destructive migrations, reset production databases, delete storage buckets, or change production auth settings without explicit approval and a verified recovery point.
