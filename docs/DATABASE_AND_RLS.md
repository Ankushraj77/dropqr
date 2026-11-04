# Database and RLS foundation

The first migration creates `profiles`, `shops`, and `shop_memberships`. Phase 2A adds `shop_settings` and `qr_stations`; it does not seed a tenant. `create_shop_with_owner` atomically creates the caller's first shop, owner membership, and initial settings.

| Table | Tenant ownership | Data API access | Row policy |
|---|---|---|---|
| `profiles` | User-owned | `authenticated`: select/insert/update | `id = auth.uid()` for every operation |
| `shops` | Tenant | `authenticated`: select | Active membership for that shop |
| `shop_memberships` | Tenant | `authenticated`: select | The signed-in user can see only their own membership rows |
| `shop_settings` | Tenant | `authenticated`: select and limited update | Active members read; active owners update; settings cannot exceed platform ceilings |
| `qr_stations` | Tenant | `authenticated`: select, limited insert/update | Active members read; active owners create/rename/disable; station identifiers are immutable |

Anonymous (`anon`) has no table grants. No client write grants exist for shops or memberships, so users cannot create or promote membership records through the Data API. Shop provisioning uses a narrow `SECURITY DEFINER` function with an empty search path and `auth.uid()` as the only source of ownership. QR station codes identify an upload entry point but never authorize access to existing files.

The shop read policy queries `shop_memberships`; the membership policy returns only rows whose `user_id` matches `auth.uid()`, keeping the membership check scoped to the signed-in identity. Authorization never reads `user_metadata` or a client-supplied `shop_id` as proof of membership.

`supabase/config.toml` sets `auto_expose_new_tables = false` so local development matches the current cloud default. The migration grants only operations with explicit policies. Keep RLS enabled when adding any exposed table and test database policies and Storage policies separately before release.

## Initial configurable shop settings

New shops receive defaults of 25 MiB per file, 20 files per session, 100 MiB
total per session, and 24-hour session expiry. These values are stored per shop.
Owners may lower them; values above the platform caps are rejected by database
constraints. Server-side upload/session enforcement is added in later Phase 2
milestones.

## Open before later phases

- Confirm the minimum shop roles for launch (the current enum has `owner` and `employee`; manager access is not included).
- Decide whether members may list other memberships in their shop and which roles may do so.
- Add audit behavior where needed, without allowing client assignment of privileged fields.
