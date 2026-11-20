-- Cole tudo no Supabase > SQL Editor > New query e clique Run.
create table if not exists public.screenshot_records (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 object_path text not null unique,
 created_at timestamptz not null default now()
);
alter table public.screenshot_records enable row level security;
drop policy if exists "read own records" on public.screenshot_records;
create policy "read own records" on public.screenshot_records for select to authenticated using (auth.uid() = user_id);
drop policy if exists "insert own records" on public.screenshot_records;
create policy "insert own records" on public.screenshot_records for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "delete own records" on public.screenshot_records;
create policy "delete own records" on public.screenshot_records for delete to authenticated using (auth.uid() = user_id);
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('prints','prints',false,20971520,array['image/jpeg','image/png','image/webp','image/heic','image/heif'])
on conflict (id) do update set public=false,file_size_limit=20971520;
drop policy if exists "upload own prints" on storage.objects;
create policy "upload own prints" on storage.objects for insert to authenticated with check (bucket_id='prints' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "read own prints" on storage.objects;
create policy "read own prints" on storage.objects for select to authenticated using (bucket_id='prints' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "delete own prints" on storage.objects;
create policy "delete own prints" on storage.objects for delete to authenticated using (bucket_id='prints' and (storage.foldername(name))[1]=auth.uid()::text);
