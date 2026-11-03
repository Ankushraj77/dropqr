# Product Requirements

## Product
DROPQR Studio is a shop-oriented file receiving and document preparation platform.

## Primary user
A digital-service shop owner or employee who receives customer documents from phones and prepares them for printing or online applications.

## Secondary user
A customer who scans a shop QR code and uploads documents without registering.

## Core workflows
1. Shop owner signs in and creates a QR station.
2. Customer scans the QR and opens a temporary upload session.
3. Customer uploads photographs, signatures, and documents.
4. Shop employee opens the session in the private inbox.
5. Employee previews files and prepares copies using Document Studio.
6. Employee downloads or saves outputs for the requested service.
7. Files expire and are deleted according to the shop's disclosed retention policy.

## Initial release priorities
P0:
- Shop authentication and tenant isolation.
- QR stations and temporary upload sessions.
- Secure mobile upload.
- Private file inbox.
- Basic file preview/download/delete.
- Image resize, compress, convert, crop and rotate.
- Configurable photo/signature presets.

P1:
- PDF merge/split/reorder/rotate/compression, subject to verified library support.
- Batch processing.
- Employee roles.
- Audit and usage visibility.

Later:
- Windows companion.
- Watch folders and global shortcuts.
- Subscription billing and public SaaS onboarding.
- Large-file resumable uploads beyond tested initial limits.

## Explicit non-goals for first release
- Full shop billing, inventory, accounting or POS.
- Public e-commerce.
- Customer accounts.
- Cloud OCR or AI document interpretation.
- Unlimited storage.
- Guaranteed 3 GB uploads.
- Native Windows context-menu integration.

## Product quality
The product must be fast, predictable, mobile-friendly, accessible, secure, and honest about supported file formats and limits.
