# Phase 2 Security Test Plan

This plan supplements the 34 baseline tenant-isolation assertions in
`supabase/tests/tenant_isolation_test.sql`. The baseline suite remains in place
and must pass after every schema milestone.

## Required Storage and upload authorization tests

| Gate | Test | Expected result |
| --- | --- | --- |
| D | Bucket privacy | The customer upload bucket is private; anonymous and authenticated users cannot read objects through public URLs. |
| D | Exact session scope | A customer capability can create objects only under its own active session's server-assigned prefix. |
| D | Upload-only | Customer credentials cannot list, read, download, update, overwrite, move, or delete objects. |
| D | No QR authorization | A permanent station QR identifier cannot authorize access to a session or existing object. |
| D | Revocation and expiry | Closed, expired, or revoked sessions reject new uploads, including retries. |
| D | Tenant isolation | A shop member and a customer session cannot read, enumerate, replace, or delete another shop's objects. |
| B/D | Quotas | Per-file size, allowed count, and aggregate session bytes are enforced, including concurrent uploads and duplicate/retry requests. |
| B/D | Content validation | Claimed MIME, extension, and detected file signature must agree with the permitted file types. |
| B/D | Path tampering | Traversal, foreign session IDs, arbitrary bucket paths, and client-chosen tenant prefixes are rejected. |
| F | Cleanup safety | Expiration removes only expired session objects and metadata; live sessions and other tenants' files remain untouched. |
| F | Cleanup recovery | Partial failures can be retried safely; orphaned objects and metadata are detected and eventually removed. |

## Milestone A authorization checks

- The original 34 assertions all pass unchanged.
- Anonymous users cannot invoke shop provisioning or read/write shop settings or QR stations.
- An authenticated user can atomically create one shop, become its owner, and receive default upload settings. A failed provisioning attempt leaves no partial rows.
- The provisioning RPC derives ownership from `auth.uid()` and ignores client-supplied ownership claims.
- A member can read only their own shop's settings and active QR stations.
- Only an active owner can create, rename, activate, or disable stations and change shop settings.
- An employee cannot mutate stations/settings; a removed or suspended member cannot access either tenant's data.
- Permanent station identifiers are public lookup identifiers only; they do not provide customer upload or file access.

## Initial configurable settings

New shops start with 25 MiB per file, 20 files per session, 100 MiB total per
session, and a 24-hour upload-session lifetime. These are tenant settings with
platform ceilings. Shops can lower their limits; increases beyond platform
ceilings require a platform-level change. Session enforcement and cleanup are
implemented in milestones B and F.
