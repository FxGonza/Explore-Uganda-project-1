-- WESTERN KICKS TECH HUB: Supabase backend schema
-- Run this entire file in Supabase Dashboard > SQL Editor > New query.

create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 120),
  category text not null,
  price bigint not null check (price >= 0),
  description text not null default '',
  image_url text not null default '',
  badge text not null default '',
  stock integer not null default 0 check (stock >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.repair_requests (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  phone text not null,
  device text not null,
  model text not null default '',
  issue text not null,
  status text not null default 'new',
  created_at timestamptz not null default now()
);

create table if not exists public.contact_enquiries (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  phone text not null,
  subject text not null default 'General enquiry',
  message text not null,
  status text not null default 'new',
  created_at timestamptz not null default now()
);

create table if not exists public.order_enquiries (
  id uuid primary key default gen_random_uuid(),
  items jsonb not null,
  total_ugx bigint not null check (total_ugx >= 0),
  status text not null default 'new',
  created_at timestamptz not null default now()
);

alter table public.admin_users enable row level security;
alter table public.products enable row level security;
alter table public.repair_requests enable row level security;
alter table public.contact_enquiries enable row level security;
alter table public.order_enquiries enable row level security;

-- Admins can verify their own membership. Do not allow public registration into this table.
drop policy if exists "Admins can read own membership" on public.admin_users;
create policy "Admins can read own membership" on public.admin_users for select to authenticated using (user_id = auth.uid());

-- Everyone can read published products. Only approved admins can create, edit or delete products.
drop policy if exists "Public can read published products" on public.products;
create policy "Public can read published products" on public.products for select to anon, authenticated using (is_active = true or exists (select 1 from public.admin_users a where a.user_id = auth.uid()));
drop policy if exists "Admins manage products" on public.products;
create policy "Admins manage products" on public.products for all to authenticated using (exists (select 1 from public.admin_users a where a.user_id = auth.uid())) with check (exists (select 1 from public.admin_users a where a.user_id = auth.uid()));

-- Public visitors may submit enquiries; only admins may read/manage them.
drop policy if exists "Visitors submit repair requests" on public.repair_requests;
create policy "Visitors submit repair requests" on public.repair_requests for insert to anon, authenticated with check (char_length(customer_name) between 1 and 120 and char_length(phone) between 5 and 40 and char_length(issue) between 1 and 3000);
drop policy if exists "Admins manage repair requests" on public.repair_requests;
create policy "Admins manage repair requests" on public.repair_requests for all to authenticated using (exists (select 1 from public.admin_users a where a.user_id = auth.uid())) with check (exists (select 1 from public.admin_users a where a.user_id = auth.uid()));
drop policy if exists "Visitors submit contact enquiries" on public.contact_enquiries;
create policy "Visitors submit contact enquiries" on public.contact_enquiries for insert to anon, authenticated with check (char_length(customer_name) between 1 and 120 and char_length(phone) between 5 and 40 and char_length(message) between 1 and 3000);
drop policy if exists "Admins manage contact enquiries" on public.contact_enquiries;
create policy "Admins manage contact enquiries" on public.contact_enquiries for all to authenticated using (exists (select 1 from public.admin_users a where a.user_id = auth.uid())) with check (exists (select 1 from public.admin_users a where a.user_id = auth.uid()));
drop policy if exists "Visitors submit order enquiries" on public.order_enquiries;
create policy "Visitors submit order enquiries" on public.order_enquiries for insert to anon, authenticated with check (jsonb_typeof(items) = 'array');
drop policy if exists "Admins manage order enquiries" on public.order_enquiries;
create policy "Admins manage order enquiries" on public.order_enquiries for all to authenticated using (exists (select 1 from public.admin_users a where a.user_id = auth.uid())) with check (exists (select 1 from public.admin_users a where a.user_id = auth.uid()));

-- Public product image bucket. Upload/delete is restricted to approved admins.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('product-images', 'product-images', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = true, file_size_limit = 5242880, allowed_mime_types = array['image/jpeg','image/png','image/webp'];

drop policy if exists "Public can view product images" on storage.objects;
create policy "Public can view product images" on storage.objects for select to anon, authenticated using (bucket_id = 'product-images');
drop policy if exists "Admins upload product images" on storage.objects;
create policy "Admins upload product images" on storage.objects for insert to authenticated with check (bucket_id = 'product-images' and exists (select 1 from public.admin_users a where a.user_id = auth.uid()));
drop policy if exists "Admins update product images" on storage.objects;
create policy "Admins update product images" on storage.objects for update to authenticated using (bucket_id = 'product-images' and exists (select 1 from public.admin_users a where a.user_id = auth.uid())) with check (bucket_id = 'product-images' and exists (select 1 from public.admin_users a where a.user_id = auth.uid()));
drop policy if exists "Admins delete product images" on storage.objects;
create policy "Admins delete product images" on storage.objects for delete to authenticated using (bucket_id = 'product-images' and exists (select 1 from public.admin_users a where a.user_id = auth.uid()));

-- IMPORTANT: After creating your first admin user in Authentication > Users,
-- copy that user's UUID and run the statement below in SQL Editor:
-- insert into public.admin_users (user_id) values ('PASTE-AUTH-USER-UUID-HERE');
