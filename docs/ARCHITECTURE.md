# Architecture

## Architectural style
Modular monolith. One Next.js application and one Supabase project per environment initially. Keep modules separated by domain boundaries.

## Main modules
- Identity and membership
- Shop/tenant management
- QR stations
- Upload sessions
- File catalog and storage
- Document processing
- Audit and retention
- Usage and quotas (later)
- Desktop device management (later)

## Request flow
Browser -> Next.js server boundary -> Supabase Auth/Postgres/Storage.

Public customer upload flow -> server validates station/session capability -> narrowly scoped upload operation -> private object storage -> metadata registration.

Do not allow anonymous users to call broad table APIs or enumerate storage objects.

## Processing
Prefer browser workers for supported operations. Define an adapter contract so a future desktop worker can perform equivalent operations. Server processing is a future option and must have explicit resource limits.

## Desktop
Tauri 2 is a later client. It uses authenticated APIs and device pairing, accesses only user-selected local files, and stores credentials in OS-backed secure storage. It is not a trusted backend and must not contain service secrets.

## Data ownership
All shop-owned rows carry shop_id. Enforce tenant membership in server code and RLS. Storage authorization must be independently enforced.

## Reliability
Use idempotency keys for retryable operations where appropriate. Model uploads and processing as explicit state machines. Cleanup must be retryable and observable.
