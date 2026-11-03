BEGIN;
SELECT plan(34);

-- Anonymous access is denied by table grants, before RLS is considered.
SELECT ok(NOT has_table_privilege('anon', 'public.profiles', 'SELECT'), 'anon cannot read profiles');
SELECT ok(NOT has_table_privilege('anon', 'public.shops', 'SELECT'), 'anon cannot read shops');
SELECT ok(NOT has_table_privilege('anon', 'public.shop_memberships', 'SELECT'), 'anon cannot read memberships');
SELECT ok(NOT has_table_privilege('anon', 'public.profiles', 'INSERT'), 'anon cannot insert profiles');
SELECT ok(NOT has_table_privilege('anon', 'public.profiles', 'UPDATE'), 'anon cannot update profiles');
SELECT ok(NOT has_table_privilege('anon', 'public.profiles', 'DELETE'), 'anon cannot delete profiles');
SELECT ok(NOT has_table_privilege('anon', 'public.shops', 'INSERT'), 'anon cannot insert shops');
SELECT ok(NOT has_table_privilege('anon', 'public.shops', 'UPDATE'), 'anon cannot update shops');
SELECT ok(NOT has_table_privilege('anon', 'public.shops', 'DELETE'), 'anon cannot delete shops');
SELECT ok(NOT has_table_privilege('anon', 'public.shop_memberships', 'INSERT'), 'anon cannot insert memberships');
SELECT ok(NOT has_table_privilege('anon', 'public.shop_memberships', 'UPDATE'), 'anon cannot update memberships');
SELECT ok(NOT has_table_privilege('anon', 'public.shop_memberships', 'DELETE'), 'anon cannot delete memberships');

-- Authenticated grants match the intended policy surface.
SELECT ok(has_table_privilege('authenticated', 'public.profiles', 'SELECT'), 'authenticated can select profiles');
SELECT ok(has_table_privilege('authenticated', 'public.profiles', 'INSERT'), 'authenticated can insert profiles');
SELECT ok(has_table_privilege('authenticated', 'public.profiles', 'UPDATE'), 'authenticated can update profiles');
SELECT ok(NOT has_table_privilege('authenticated', 'public.profiles', 'DELETE'), 'authenticated cannot delete profiles');
SELECT ok(has_table_privilege('authenticated', 'public.shops', 'SELECT'), 'authenticated can select shops');
SELECT ok(NOT has_table_privilege('authenticated', 'public.shops', 'INSERT'), 'authenticated cannot insert shops');
SELECT ok(NOT has_table_privilege('authenticated', 'public.shops', 'UPDATE'), 'authenticated cannot update shops');
SELECT ok(NOT has_table_privilege('authenticated', 'public.shops', 'DELETE'), 'authenticated cannot delete shops');
SELECT ok(has_table_privilege('authenticated', 'public.shop_memberships', 'SELECT'), 'authenticated can select memberships');
SELECT ok(NOT has_table_privilege('authenticated', 'public.shop_memberships', 'INSERT'), 'authenticated cannot insert memberships');
SELECT ok(NOT has_table_privilege('authenticated', 'public.shop_memberships', 'UPDATE'), 'authenticated cannot update memberships');
SELECT ok(NOT has_table_privilege('authenticated', 'public.shop_memberships', 'DELETE'), 'authenticated cannot delete memberships');

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

CREATE FUNCTION pg_temp.row_count(statement text)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE affected integer;
BEGIN
  EXECUTE statement;
  GET DIAGNOSTICS affected = ROW_COUNT;
  RETURN affected;
END;
$$;

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims = '{"sub":"10000000-0000-4000-8000-000000000001","role":"authenticated"}';
SELECT is((SELECT count(*)::int FROM public.profiles), 1, 'user A reads only own profile');
SELECT is((SELECT count(*)::int FROM public.shops), 1, 'user A reads only member shop');
SELECT is((SELECT count(*)::int FROM public.shop_memberships), 1, 'user A reads only own membership');
SELECT is(pg_temp.row_count('UPDATE public.profiles SET display_name = ''intruded'' WHERE id = ''20000000-0000-4000-8000-000000000002'''), 0, 'user A cannot update user B profile');
SELECT is(pg_temp.row_count('UPDATE public.profiles SET display_name = ''Owner A Updated'' WHERE id = ''10000000-0000-4000-8000-000000000001'''), 1, 'user A can update own profile');

SET LOCAL request.jwt.claims = '{"sub":"20000000-0000-4000-8000-000000000002","role":"authenticated"}';
SELECT is((SELECT count(*)::int FROM public.profiles), 1, 'user B reads only own profile');
SELECT is((SELECT count(*)::int FROM public.shops), 1, 'user B reads only member shop');
SELECT is((SELECT count(*)::int FROM public.shop_memberships), 1, 'user B reads only own membership');
SELECT is(pg_temp.row_count('UPDATE public.profiles SET display_name = ''intruded'' WHERE id = ''10000000-0000-4000-8000-000000000001'''), 0, 'user B cannot update user A profile');
SELECT is(pg_temp.row_count('UPDATE public.profiles SET display_name = ''Owner B Updated'' WHERE id = ''20000000-0000-4000-8000-000000000002'''), 1, 'user B can update own profile');

RESET ROLE;
SELECT * FROM finish();
ROLLBACK;

