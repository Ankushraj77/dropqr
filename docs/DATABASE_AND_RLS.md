# Database and RLS foundation

The first migration creates `profiles`, `shops`, and `shop_memberships`. It intentionally does not add a seed tenant or client-side shop creation path. The first shop and its owner membership must be created by a validated server onboarding operation in a later step.

| Table | Tenant ownership | Data API access | Row policy |
|---|---|---|---|
| `profiles` | User-owned | `authenticated`: select/insert/update | `id = auth.uid()` for every operation |
| `shops` | Tenant | `authenticated`: select | Active membership for that shop |
| `shop_memberships` | Tenant | `authenticated`: select | The signed-in user can see only their own membership rows |

Anonymous (`anon`) has no table grants. No client write grants exist for shops or memberships, so users cannot create or promote membership records through the Data API. Shop provisioning, role changes, audit events, QR stations, files, and storage policies are intentionally not implemented in this migration.

The shop read policy queries `shop_memberships`; the membership policy returns only rows whose `user_id` matches `auth.uid()`, keeping the membership check scoped to the signed-in identity. Authorization never reads `user_metadata` or a client-supplied `shop_id` as proof of membership.

`supabase/config.toml` sets `auto_expose_new_tables = false` so local development matches the current cloud default. The migration grants only operations with explicit policies. Keep RLS enabled when adding any exposed table and test database policies and Storage policies separately before release.

## Open before onboarding

- Confirm the minimum shop roles for launch (the current enum has `owner` and `employee`; manager access is not included).
- Implement atomic shop creation plus owner membership through a server-authorized flow.
- Decide whether members may list other memberships in their shop and which roles may do so.
- Add update timestamps and audit behavior where needed, without allowing client assignment of privileged fields.
