# Security and Privacy Requirements

## Threats to address
- Cross-tenant data exposure.
- Guessable or leaked upload session tokens.
- Public access to private storage.
- MIME spoofing and malicious file uploads.
- Oversized uploads and resource exhaustion.
- Unauthorized file downloads or deletion.
- Leaked desktop credentials.
- Accidental deletion during cleanup.
- Secrets committed to GitHub.
- Sensitive filenames or tokens appearing in logs.

## Controls
- High-entropy session capabilities; store hashes where practical.
- Upload-only scope for customer capabilities.
- Short expiration and revocation.
- Per-file, per-session and per-shop quotas.
- Rate limits on public endpoints.
- Validate actual file signatures and supported formats.
- Private buckets and short-lived authorized downloads.
- RLS on all exposed tenant-owned tables.
- Server-side membership and role checks.
- Token refresh at the request proxy is not authorization; privileged operations validate membership and role at their own server boundary.
- No authorization from user-editable metadata.
- No service-role key in client code.
- Opaque storage keys; sanitize display names.
- Audit security-sensitive operations.
- Redact tokens and document content from logs.
- Desktop secrets in OS credential storage.
- Regular dependency and deployment review.

## Retention
The initial configurable shop defaults are 25 MiB per file, 20 files per session,
100 MiB total per session, and 24-hour session expiry, subject to platform caps.
Milestone B will enforce them for new sessions, and milestone F will remove
expired metadata and objects, retry failures, and report orphaned objects.

## Backup
Define database and object-storage backup/recovery separately. A database backup alone does not restore uploaded files. Test restoration before production reliance.

## Release blockers
Any unresolved cross-tenant access, public storage exposure, unbounded upload, leaked secret, or untested deletion path blocks production release.

The required milestone-by-milestone Storage and tenant security checks are
tracked in `PHASE_2_SECURITY_TEST_PLAN.md`.
