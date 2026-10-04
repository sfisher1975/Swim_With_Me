-- Run this file in the existing Swim With Me Supabase SQL editor.
-- Do not rerun schema.sql. This additive migration can be rerun.
begin;
create table if not exists public.race_messages (
 id uuid primary key default gen_random_uuid(),
 swim_id uuid not null references public.swims(id) on delete cascade,
 sender_id uuid not null references auth.users(id) on delete cascade,
 sender_name text not null check(char_length(trim(sender_name)) between 1 and 60),
 body text not null check(char_length(trim(body)) between 1 and 1000),
 created_at timestamptz not null default now()
);
create index if not exists race_messages_thread_idx on public.race_messages(swim_id,created_at,id);
alter table public.race_messages enable row level security;
grant select, insert on public.race_messages to authenticated;
revoke all on public.race_messages from anon;
drop policy if exists race_messages_read on public.race_messages;
create policy race_messages_read on public.race_messages for select to authenticated
 using (exists(select 1 from public.swims s where s.id=swim_id and public.can_view_swimmer(s.swimmer_id)));
drop policy if exists race_messages_send on public.race_messages;
create policy race_messages_send on public.race_messages for insert to authenticated
 with check (sender_id=(select auth.uid()) and exists(select 1 from public.swims s join public.swimmers k on k.id=s.swimmer_id where s.id=swim_id and public.can_view_swimmer(s.swimmer_id) and public.is_family_member(k.family_id)));
-- Server timestamp and signed-in sender cannot be forged by a client.
create or replace function public.stamp_race_message() returns trigger language plpgsql set search_path=public as $$
begin
 new.sender_id := auth.uid();
 new.created_at := now();
 new.sender_name := trim(new.sender_name);
 new.body := trim(new.body);
 return new;
end $$;
drop trigger if exists stamp_race_message on public.race_messages;
create trigger stamp_race_message before insert on public.race_messages for each row execute function public.stamp_race_message();
commit;
notify pgrst, 'reload schema';
