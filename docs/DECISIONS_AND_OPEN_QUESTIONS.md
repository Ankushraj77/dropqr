# Decisions and Open Questions

## Decisions already selected
- Product combines DROPQR file receiving and Tangerine-inspired document processing.
- Clean rebuild; do not depend on Bolt source code.
- Web application plus Windows desktop helper later.
- Next.js + TypeScript.
- Supabase for database, auth and storage.
- Vercel hosting.
- GitHub source control.
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
- 24-hour session expiry as a proposed default only.
- Conservative initial upload limit; no 3 GB guarantee at launch.
- Windows companion after web product is stable.

## Questions Codex must raise before implementation where they affect schema or security
1. What initial maximum file size and maximum files per session should be enforced?
2. What retention period should be disclosed to customers?
3. Which image formats and PDF operations are essential for the first release?
4. Is customer upload allowed only while the shop is open, or at any time?
5. Which shop roles are required in the first release?
6. Should locally imported files be cloud-saved by default or only on explicit action?
7. What backup and recovery expectations apply to originals and processed outputs?

Codex should propose safe defaults and explain trade-offs rather than silently inventing answers.
