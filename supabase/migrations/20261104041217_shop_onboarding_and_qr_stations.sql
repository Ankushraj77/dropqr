-- Phase 2A: atomically provision a shop, owner membership, and configurable
-- upload defaults, then manage permanent QR station identifiers.

create table public.shop_settings (
  shop_id uuid primary key references public.shops (id) on delete cascade,
  max_file_size_bytes integer not null default 26214400
    check (max_file_size_bytes between 1 and 26214400),
  max_files_per_session integer not null default 20
    check (max_files_per_session between 1 and 20),
  max_total_bytes_per_session bigint not null default 104857600
    check (max_total_bytes_per_session between 1 and 104857600),
  session_ttl_hours integer not null default 24
    check (session_ttl_hours between 1 and 24),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.qr_stations (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.shops (id) on delete cascade,
  station_code uuid not null unique default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 1 and 80),
  is_active boolean not null default true,
  created_by uuid not null references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (shop_id, id)
);

create index qr_stations_shop_active_idx
  on public.qr_stations (shop_id, is_active, created_at desc);

create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

revoke all on function public.set_updated_at() from public, anon, authenticated;

create trigger shop_settings_set_updated_at
before update on public.shop_settings
for each row execute function public.set_updated_at();

create trigger qr_stations_set_updated_at
before update on public.qr_stations
for each row execute function public.set_updated_at();

alter table public.shop_settings enable row level security;
alter table public.shop_settings force row level security;
alter table public.qr_stations enable row level security;
alter table public.qr_stations force row level security;

create policy "shop_settings_select_active_member"
  on public.shop_settings
  for select to authenticated
  using (
    exists (
      select 1 from public.shop_memberships as membership
      where membership.shop_id = shop_settings.shop_id
        and membership.user_id = (select auth.uid())
        and membership.status = 'active'
    )
  );

create policy "shop_settings_update_active_owner"
  on public.shop_settings
  for update to authenticated
  using (
    exists (
      select 1 from public.shop_memberships as membership
      where membership.shop_id = shop_settings.shop_id
        and membership.user_id = (select auth.uid())
        and membership.role = 'owner'
        and membership.status = 'active'
    )
  )
  with check (
    exists (
      select 1 from public.shop_memberships as membership
      where membership.shop_id = shop_settings.shop_id
        and membership.user_id = (select auth.uid())
        and membership.role = 'owner'
        and membership.status = 'active'
    )
  );

create policy "qr_stations_select_active_member"
  on public.qr_stations
  for select to authenticated
  using (
    exists (
      select 1 from public.shop_memberships as membership
      where membership.shop_id = qr_stations.shop_id
        and membership.user_id = (select auth.uid())
        and membership.status = 'active'
    )
  );

create policy "qr_stations_insert_active_owner"
  on public.qr_stations
  for insert to authenticated
  with check (
    created_by = (select auth.uid())
    and exists (
      select 1 from public.shop_memberships as membership
      where membership.shop_id = qr_stations.shop_id
        and membership.user_id = (select auth.uid())
        and membership.role = 'owner'
        and membership.status = 'active'
    )
  );

create policy "qr_stations_update_active_owner"
  on public.qr_stations
  for update to authenticated
  using (
    exists (
      select 1 from public.shop_memberships as membership
      where membership.shop_id = qr_stations.shop_id
        and membership.user_id = (select auth.uid())
        and membership.role = 'owner'
        and membership.status = 'active'
    )
  )
  with check (
    exists (
      select 1 from public.shop_memberships as membership
      where membership.shop_id = qr_stations.shop_id
        and membership.user_id = (select auth.uid())
        and membership.role = 'owner'
        and membership.status = 'active'
    )
  );

-- The caller cannot choose a user ID or membership role. This narrowly scoped
-- function is the only client path that creates a shop and its first owner.
create function public.create_shop_with_owner(p_name text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_shop_id uuid;
begin
  if v_user_id is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  if p_name is null or char_length(btrim(p_name)) not between 1 and 120 then
    raise exception 'Shop name must contain between 1 and 120 characters' using errcode = '22023';
  end if;

  insert into public.profiles (id)
  values (v_user_id)
  on conflict (id) do nothing;

  insert into public.shops (name, created_by)
  values (btrim(p_name), v_user_id)
  returning id into v_shop_id;

  insert into public.shop_memberships (shop_id, user_id, role, status)
  values (v_shop_id, v_user_id, 'owner', 'active');

  insert into public.shop_settings (shop_id)
  values (v_shop_id);

  return v_shop_id;
end;
$$;

revoke all on function public.create_shop_with_owner(text) from public, anon;
grant execute on function public.create_shop_with_owner(text) to authenticated;

revoke all on table public.shop_settings, public.qr_stations from anon, authenticated;
grant select on table public.shop_settings, public.qr_stations to authenticated;
grant update (max_file_size_bytes, max_files_per_session, max_total_bytes_per_session, session_ttl_hours)
  on table public.shop_settings to authenticated;
grant insert (shop_id, name, created_by), update (name, is_active)
  on table public.qr_stations to authenticated;
