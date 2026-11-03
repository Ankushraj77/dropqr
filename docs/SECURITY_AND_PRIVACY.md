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
The initial 24-hour session expiry is a proposal only. The owner must approve a clear retention period and customer-facing disclosure before production. Deletion jobs must remove both metadata and objects, retry failures, and report orphaned objects.

## Backup
Define database and object-storage backup/recovery separately. A database backup alone does not restore uploaded files. Test restoration before production reliance.

## Release blockers
Any unresolved cross-tenant access, public storage exposure, unbounded upload, leaked secret, or untested deletion path blocks production release.
