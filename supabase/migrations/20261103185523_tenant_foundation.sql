-- DROPQR Studio tenant foundation.
-- Tenant provisioning and membership mutation are intentionally deferred to a
-- server-authorized onboarding flow; these tables have no client write policy.

create type public.shop_role as enum ('owner', 'employee');

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.shops (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 1 and 120),
  created_by uuid not null references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.shop_memberships (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.shops (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  role public.shop_role not null,
  status text not null default 'active' check (status in ('active', 'suspended', 'removed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (shop_id, user_id)
);

create index shop_memberships_user_shop_idx
  on public.shop_memberships (user_id, shop_id)
  where status = 'active';

alter table public.profiles enable row level security;
alter table public.profiles force row level security;
alter table public.shops enable row level security;
alter table public.shops force row level security;
alter table public.shop_memberships enable row level security;
alter table public.shop_memberships force row level security;

create policy "profiles_select_self"
  on public.profiles
  for select to authenticated
  using ((select auth.uid()) = id);

create policy "profiles_insert_self"
  on public.profiles
  for insert to authenticated
  with check ((select auth.uid()) = id);

create policy "profiles_update_self"
  on public.profiles
  for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create policy "shops_select_member"
  on public.shops
  for select to authenticated
  using (
    exists (
      select 1
      from public.shop_memberships as membership
      where membership.shop_id = shops.id
        and membership.user_id = (select auth.uid())
        and membership.status = 'active'
    )
  );

create policy "shop_memberships_select_self"
  on public.shop_memberships
  for select to authenticated
  using ((select auth.uid()) = user_id);

-- Supabase changed default Data API exposure behavior in 2026. Grant only the
-- operations backed by explicit RLS policies; anonymous users get no access.
revoke all on table public.profiles, public.shops, public.shop_memberships from anon, authenticated;
grant usage on schema public to authenticated;
grant select, insert, update on table public.profiles to authenticated;
grant select on table public.shops, public.shop_memberships to authenticated;
