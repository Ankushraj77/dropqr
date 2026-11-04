# Decisions and Open Questions

## Decisions already selected
- Product combines DROPQR file receiving and Tangerine-inspired document processing.
- Clean rebuild; do not depend on Bolt source code.
- Web application plus Windows desktop helper later.
- Next.js + TypeScript.
- Supabase for database, auth and storage.
- Vercel hosting.
- GitHub source control.
- Email/password authentication through Supabase Auth.
- Initial shop upload settings: 25 MiB per file, 20 files per session, 100 MiB total per session, and 24-hour session expiry. These are configurable shop settings, with platform ceilings.
- First operational tenant: AK DIGITAL SERVICES.
- Future product: multi-shop SaaS.
- One integrated product, not separate apps.

## Recommended defaults pending owner approval
- Private GitHub monorepo.
- Modular monolith.
- Browser/local processing first.
- Private storage.
- No customer account.
- Temporary upload sessions.
- Conservative initial upload limit; no 3 GB guarantee at launch.
- Windows companion after web product is stable.

## Open decisions for later phases
1. What retention period should be disclosed to customers beyond the upload-session expiry?
2. Which image formats and PDF operations are essential for the first release?
3. Is customer upload allowed only while the shop is open, or at any time?
4. Which shop roles are required in the first release?
5. Should locally imported files be cloud-saved by default or only on explicit action?
6. What backup and recovery expectations apply to originals and processed outputs?

Items not specified above remain open. Proposed or implemented defaults should be documented and kept configurable where practical.
