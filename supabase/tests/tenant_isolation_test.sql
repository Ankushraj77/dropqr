BEGIN;
SELECT plan(19);

-- Anonymous access is denied by table grants, before RLS is considered.
SELECT ok(NOT has_table_privilege('anon', 'public.profiles', 'SELECT'), 'anon cannot read profiles');
SELECT ok(NOT has_table_privilege('anon', 'public.shops', 'SELECT'), 'anon cannot read shops');
SELECT ok(NOT has_table_privilege('anon', 'public.shop_memberships', 'SELECT'), 'anon cannot read memberships');

-- Authenticated grants match the intended policy surface.
SELECT ok(has_table_privilege('authenticated', 'public.profiles', 'SELECT,INSERT,UPDATE'), 'authenticated can select and mutate profiles');
SELECT ok(NOT has_table_privilege('authenticated', 'public.profiles', 'DELETE'), 'authenticated cannot delete profiles');
SELECT ok(has_table_privilege('authenticated', 'public.shops', 'SELECT'), 'authenticated can select shops');
SELECT ok(NOT has_table_privilege('authenticated', 'public.shops', 'INSERT,UPDATE,DELETE'), 'authenticated cannot mutate shops');
SELECT ok(has_table_privilege('authenticated', 'public.shop_memberships', 'SELECT'), 'authenticated can select memberships');
SELECT ok(NOT has_table_privilege('authenticated', 'public.shop_memberships', 'INSERT,UPDATE,DELETE'), 'authenticated cannot mutate memberships');

INSERT INTO auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data)
VALUES
  ('10000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner-a@example.test', '', now(), '{}'::jsonb, '{}'::jsonb),
  ('20000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'owner-b@example.test', '', now(), '{}'::jsonb, '{}'::jsonb);

INSERT INTO public.profiles (id, display_name) VALUES
  ('10000000-0000-4000-8000-000000000001', 'Owner A'),
  ('20000000-0000-4000-8000-000000000002', 'Owner B');
INSERT INTO public.shops (id, name, created_by) VALUES
  ('a0000000-0000-4000-8000-000000000001', 'Shop A', '10000000-0000-4000-8000-000000000001'),
  ('b0000000-0000-4000-8000-000000000002', 'Shop B', '20000000-0000-4000-8000-000000000002');
INSERT INTO public.shop_memberships (shop_id, user_id, role) VALUES
  ('a0000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'owner'),
  ('b0000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000002', 'owner');

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims = '{"sub":"10000000-0000-4000-8000-000000000001","role":"authenticated"}';
SELECT is((SELECT count(*)::int FROM public.profiles), 1, 'user A reads only own profile');
SELECT is((SELECT count(*)::int FROM public.shops), 1, 'user A reads only member shop');
SELECT is((SELECT count(*)::int FROM public.shop_memberships), 1, 'user A reads only own membership');
SELECT is((WITH changed AS (UPDATE public.profiles SET display_name = 'intruded' WHERE id = '20000000-0000-4000-8000-000000000002' RETURNING 1) SELECT count(*)::int FROM changed), 0, 'user A cannot update user B profile');
SELECT is((WITH changed AS (UPDATE public.profiles SET display_name = 'Owner A Updated' WHERE id = '10000000-0000-4000-8000-000000000001' RETURNING 1) SELECT count(*)::int FROM changed), 1, 'user A can update own profile');

SET LOCAL request.jwt.claims = '{"sub":"20000000-0000-4000-8000-000000000002","role":"authenticated"}';
SELECT is((SELECT count(*)::int FROM public.profiles), 1, 'user B reads only own profile');
SELECT is((SELECT count(*)::int FROM public.shops), 1, 'user B reads only member shop');
SELECT is((SELECT count(*)::int FROM public.shop_memberships), 1, 'user B reads only own membership');
SELECT is((WITH changed AS (UPDATE public.profiles SET display_name = 'intruded' WHERE id = '10000000-0000-4000-8000-000000000001' RETURNING 1) SELECT count(*)::int FROM changed), 0, 'user B cannot update user A profile');
SELECT is((WITH changed AS (UPDATE public.profiles SET display_name = 'Owner B Updated' WHERE id = '20000000-0000-4000-8000-000000000002' RETURNING 1) SELECT count(*)::int FROM changed), 1, 'user B can update own profile');

RESET ROLE;
SELECT * FROM finish();
ROLLBACK;
