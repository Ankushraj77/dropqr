BEGIN;
SELECT plan(42);

-- Anonymous and authenticated SQL privileges are narrower than table access.
SELECT ok(NOT has_table_privilege('anon', 'public.shop_settings', 'SELECT'), 'anon cannot read shop settings');
SELECT ok(NOT has_table_privilege('anon', 'public.shop_settings', 'UPDATE'), 'anon cannot update shop settings');
SELECT ok(NOT has_table_privilege('anon', 'public.qr_stations', 'SELECT'), 'anon cannot read QR stations');
SELECT ok(NOT has_table_privilege('anon', 'public.qr_stations', 'INSERT'), 'anon cannot create QR stations');
SELECT ok(NOT has_function_privilege('anon', 'public.create_shop_with_owner(text)', 'EXECUTE'), 'anon cannot provision shops');
SELECT ok(has_function_privilege('authenticated', 'public.create_shop_with_owner(text)', 'EXECUTE'), 'authenticated can provision own shop');
SELECT ok(has_table_privilege('authenticated', 'public.shop_settings', 'SELECT'), 'authenticated has settings select privilege');
SELECT ok(NOT has_table_privilege('authenticated', 'public.shop_settings', 'UPDATE'), 'settings updates are restricted to approved columns');
SELECT ok(has_column_privilege('authenticated', 'public.shop_settings', 'max_file_size_bytes', 'UPDATE'), 'authenticated may update upload setting columns');
SELECT ok(NOT has_table_privilege('authenticated', 'public.shop_settings', 'INSERT'), 'authenticated cannot directly create settings');
SELECT ok(NOT has_table_privilege('authenticated', 'public.shop_settings', 'DELETE'), 'authenticated cannot delete settings');
SELECT ok(has_table_privilege('authenticated', 'public.qr_stations', 'SELECT'), 'authenticated has station select privilege');
SELECT ok(NOT has_table_privilege('authenticated', 'public.qr_stations', 'INSERT'), 'station insert is restricted to approved columns');
SELECT ok(has_column_privilege('authenticated', 'public.qr_stations', 'shop_id', 'INSERT'), 'authenticated may supply station tenant for RLS validation');
SELECT ok(has_column_privilege('authenticated', 'public.qr_stations', 'name', 'UPDATE'), 'authenticated may update station name');
SELECT ok(NOT has_column_privilege('authenticated', 'public.qr_stations', 'shop_id', 'UPDATE'), 'authenticated cannot move a station to another shop');
SELECT ok(NOT has_column_privilege('authenticated', 'public.qr_stations', 'station_code', 'UPDATE'), 'authenticated cannot change permanent station code');
SELECT ok(NOT has_table_privilege('authenticated', 'public.qr_stations', 'DELETE'), 'authenticated cannot delete stations');

INSERT INTO auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data)
VALUES
  ('10000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner-a@example.test', '', now(), '{}'::jsonb, '{}'::jsonb),
  ('20000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'owner-b@example.test', '', now(), '{}'::jsonb, '{}'::jsonb),
  ('30000000-0000-4000-8000-000000000003', 'authenticated', 'authenticated', 'employee-a@example.test', '', now(), '{}'::jsonb, '{}'::jsonb);

CREATE TEMP TABLE provisioned_shop (user_key text primary key, shop_id uuid not null);
GRANT INSERT, SELECT ON provisioned_shop TO authenticated;

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
INSERT INTO provisioned_shop
SELECT 'a', public.create_shop_with_owner('Shop A');
SELECT is((SELECT count(*)::int FROM public.shops), 1, 'onboarding creates exactly one visible shop');
SELECT is((SELECT count(*)::int FROM public.shop_memberships WHERE role = 'owner' AND status = 'active'), 1, 'onboarding atomically creates active owner membership');
SELECT is((SELECT count(*)::int FROM public.shop_settings WHERE max_file_size_bytes = 26214400 AND max_files_per_session = 20 AND max_total_bytes_per_session = 104857600 AND session_ttl_hours = 24), 1, 'onboarding installs the documented default settings');
SELECT is((SELECT count(*)::int FROM public.profiles WHERE id = auth.uid()), 1, 'onboarding creates the authenticated user profile');
INSERT INTO public.qr_stations (shop_id, name, created_by)
SELECT shop_id, 'Front counter', auth.uid() FROM provisioned_shop WHERE user_key = 'a';
SELECT is((SELECT count(*)::int FROM public.qr_stations), 1, 'owner can create a permanent QR station');

SET LOCAL request.jwt.claims = '{"sub":"20000000-0000-4000-8000-000000000002","role":"authenticated"}';
INSERT INTO provisioned_shop
SELECT 'b', public.create_shop_with_owner('Shop B');
INSERT INTO public.qr_stations (shop_id, name, created_by)
SELECT shop_id, 'Shop B station', auth.uid() FROM provisioned_shop WHERE user_key = 'b';
SELECT is((SELECT count(*)::int FROM public.shops), 1, 'second owner sees only their provisioned shop');

RESET ROLE;
INSERT INTO public.shop_memberships (shop_id, user_id, role, status)
SELECT shop_id, '30000000-0000-4000-8000-000000000003', 'employee', 'active'
FROM provisioned_shop WHERE user_key = 'a';

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims = '{"sub":"10000000-0000-4000-8000-000000000001","role":"authenticated"}';
SELECT is((SELECT count(*)::int FROM public.shops), 1, 'owner A cannot see shop B');
SELECT is((SELECT count(*)::int FROM public.shop_settings), 1, 'owner A cannot see shop B settings');
SELECT is((SELECT count(*)::int FROM public.qr_stations), 1, 'owner A cannot see shop B station');
SELECT is(pg_temp.row_count('UPDATE public.shop_settings SET session_ttl_hours = 1 WHERE shop_id = (SELECT shop_id FROM provisioned_shop WHERE user_key = ''b'')'), 0, 'owner A cannot update shop B settings');
SELECT is(pg_temp.row_count('UPDATE public.qr_stations SET name = ''intruded'' WHERE name = ''Shop B station'''), 0, 'owner A cannot rename shop B station');
SELECT is(pg_temp.row_count('UPDATE public.shop_settings SET max_file_size_bytes = 1048576 WHERE shop_id = (SELECT shop_id FROM provisioned_shop WHERE user_key = ''a'')'), 1, 'owner A can lower their file-size setting');
SELECT is(pg_temp.row_count('UPDATE public.qr_stations SET name = ''Front desk'' WHERE name = ''Front counter'''), 1, 'owner A can rename their station');
SELECT throws_ok(
  $$UPDATE public.shop_settings SET max_file_size_bytes = 26214401 WHERE shop_id = (SELECT shop_id FROM provisioned_shop WHERE user_key = 'a')$$,
  '23514', NULL, 'shop settings cannot exceed the platform ceiling'
);

SET LOCAL request.jwt.claims = '{"sub":"30000000-0000-4000-8000-000000000003","role":"authenticated"}';
SELECT is((SELECT count(*)::int FROM public.shops), 1, 'active employee can read their shop');
SELECT is((SELECT count(*)::int FROM public.qr_stations), 1, 'active employee can read their shop station');
SELECT is(pg_temp.row_count('UPDATE public.shop_settings SET session_ttl_hours = 12 WHERE shop_id = (SELECT shop_id FROM provisioned_shop WHERE user_key = ''a'')'), 0, 'employee cannot change upload settings');
SELECT is(pg_temp.row_count('UPDATE public.qr_stations SET is_active = false WHERE name = ''Front desk'''), 0, 'employee cannot disable a station');
SELECT throws_ok(
  $$INSERT INTO public.qr_stations (shop_id, name, created_by) SELECT shop_id, 'employee station', auth.uid() FROM provisioned_shop WHERE user_key = 'a'$$,
  '42501', NULL, 'employee cannot create a QR station'
);

RESET ROLE;
UPDATE public.shop_memberships
SET status = 'suspended'
WHERE user_id = '30000000-0000-4000-8000-000000000003';
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims = '{"sub":"30000000-0000-4000-8000-000000000003","role":"authenticated"}';
SELECT is((SELECT count(*)::int FROM public.shops), 0, 'suspended employee cannot see shops');
SELECT is((SELECT count(*)::int FROM public.shop_settings), 0, 'suspended employee cannot see settings');
SELECT is((SELECT count(*)::int FROM public.qr_stations), 0, 'suspended employee cannot see stations');
SELECT throws_ok($$SELECT public.create_shop_with_owner('   ')$$, '22023', NULL, 'empty shop names are rejected');
SET LOCAL request.jwt.claims = '{"sub":"10000000-0000-4000-8000-000000000001","role":"authenticated"}';
SELECT is((SELECT count(*)::int FROM public.shops), 1, 'rejected onboarding leaves no partial shop');

RESET ROLE;
SELECT * FROM finish();
ROLLBACK;
