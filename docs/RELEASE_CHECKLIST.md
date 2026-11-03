# Release Checklist

## Security
- [ ] RLS enabled on every exposed tenant-owned table.
- [ ] Cross-tenant negative tests pass.
- [ ] Storage buckets are private.
- [ ] Customer capability is upload-only and session-scoped.
- [ ] File signatures and sizes are validated.
- [ ] Rate limits and quotas are active.
- [ ] No secrets in Git or client bundles.
- [ ] Download and delete authorization tested.

## Reliability
- [ ] Upload retries tested.
- [ ] Expiration and cleanup tested.
- [ ] Orphan cleanup/reconciliation available.
- [ ] Original files preserved.
- [ ] Processing errors handled.
- [ ] Backup and restore tested.

## Product
- [ ] Mobile upload works on representative Android devices.
- [ ] Shop inbox works at target screen sizes.
- [ ] Empty, loading, success and failure states exist.
- [ ] Keyboard accessibility checked.
- [ ] Supported format matrix published.

## Deployment
- [ ] Preview deployment verified.
- [ ] Environment variables reviewed.
- [ ] Database migrations reviewed and applied to correct environment.
- [ ] Production approval obtained.
- [ ] Rollback plan documented.
